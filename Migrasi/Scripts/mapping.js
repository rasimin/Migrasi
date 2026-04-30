// ===== Mapping Modal Logic =====
let mappingModal;
let currentTargetDb = "";
let fileColumns = [];     // columns parsed from uploaded TXT
let spParams = [];        // SP parameters loaded from server
let sampleRows = [];      // sample data rows from TXT

$(document).ready(function () {
    const el = document.getElementById('mappingModal');
    mappingModal = new bootstrap.Modal(el, { focus: false });
});

// === Open Modal ===
function openMappingModal(id, spName, targetDb) {
    $('#mapConfigID').text(id);
    $('#mapSPName').text(spName || '—');
    currentTargetDb = targetDb || "";
    fileColumns = [];
    spParams = [];
    sampleRows = [];
    $('#samplePreview').addClass('d-none');
    $('#btnAutoMatch').prop('disabled', true);
    $('#btnSaveMapping').prop('disabled', true);
    $('#mappingStats').addClass('d-none');
    document.getElementById('sampleFile').value = '';
    loadSPParameters(spName, targetDb, id);
    mappingModal.show();
}

// === Load SP Params ===
function loadSPParameters(spName, targetDb, configId) {
    $('#mappingContent').html('<div class="text-center py-5"><div class="spinner-border text-primary"></div><p class="text-muted mt-2 small">Loading parameters...</p></div>');
    if (!spName || spName.trim() === "") { showNoSPUI(spName, configId); return; }

    $.ajax({
        type: "POST", url: "Maintenance.aspx/GetSPParameters",
        data: JSON.stringify({ spName: spName, targetDb: targetDb, configId: configId }),
        contentType: "application/json; charset=utf-8", dataType: "json",
        success: function (r) {
            spParams = r.d;
            if (spParams.length === 0) { showNoSPUI(spName, configId); return; }
            renderMappingTable();
        },
        error: function () { showAlert('Error', 'Failed to load SP parameters.', 'error'); }
    });
}

// === Render Mapping Table ===
function renderMappingTable() {
    let html = '<div class="card border-0 shadow-sm rounded-4 overflow-hidden"><div class="card-header border-0 py-2 px-3 d-flex align-items-center" style="background:var(--table-header);">';
    html += '<h6 class="mb-0 small fw-bold"><i class="bi bi-database-fill me-2 text-primary"></i>PARAMETER MAPPING</h6>';
    html += '<span class="badge bg-primary bg-opacity-10 text-primary ms-2 small">' + spParams.length + ' params</span></div>';
    html += '<div class="card-body p-0"><table class="mapping-table"><thead><tr>';
    html += '<th style="width:40px">#</th><th>SP Parameter</th><th style="width:120px">Type</th>';
    html += '<th style="width:50px;text-align:center"><i class="bi bi-arrow-left-right"></i></th>';
    html += '<th class="col-select">File Column</th><th style="width:80px">Status</th></tr></thead><tbody>';

    spParams.forEach(function (p, i) {
        var selVal = p.MappedColumn || "";
        html += '<tr><td class="text-muted small">' + (i + 1) + '</td>';
        html += '<td><span class="fw-bold font-monospace">' + escHtml(p.ParamName) + '</span></td>';
        html += '<td><span class="badge bg-light text-dark border small">' + escHtml(p.DataType) + '</span></td>';
        html += '<td class="text-center"><i class="bi bi-arrow-right-short arrow-icon"></i></td>';
        html += '<td class="col-select"><select class="form-select form-select-sm map-select' + (selVal ? ' mapped' : '') + '" data-param="' + escHtml(p.ParamName) + '" onchange="onMapChange(this)">';
        html += '<option value="">-- select column --</option>';
        fileColumns.forEach(function (c) {
            html += '<option value="' + escHtml(c) + '"' + (c === selVal ? ' selected' : '') + '>' + escHtml(c) + '</option>';
        });
        html += '</select></td>';
        html += '<td class="text-center">' + (selVal ? '<i class="bi bi-check-circle-fill text-success"></i>' : '<i class="bi bi-dash-circle text-muted opacity-50"></i>') + '</td>';
        html += '</tr>';
    });

    html += '</tbody></table></div></div>';
    // Add hint if no columns loaded yet
    if (fileColumns.length === 0) {
        html += '<div class="alert alert-info border-0 mt-3 small d-flex align-items-center"><i class="bi bi-lightbulb me-2 fs-5"></i><div><b>Tip:</b> Upload a sample TXT file to populate the column dropdowns, then map each parameter.</div></div>';
    }
    $('#mappingContent').html(html);
    updateMappingStats();
    if (fileColumns.length > 0) $('#btnAutoMatch').prop('disabled', false);
}

function onMapChange(sel) {
    var $s = $(sel);
    if ($s.val()) { $s.addClass('mapped'); $s.closest('tr').find('td:last i').attr('class', 'bi bi-check-circle-fill text-success'); }
    else { $s.removeClass('mapped'); $s.closest('tr').find('td:last i').attr('class', 'bi bi-dash-circle text-muted opacity-50'); }
    updateMappingStats();
}

function updateMappingStats() {
    var total = $('.map-select').length;
    var mapped = $('.map-select').filter(function () { return $(this).val() !== ""; }).length;
    if (total > 0) {
        $('#mappingStats').text(mapped + ' / ' + total + ' mapped').removeClass('d-none');
        $('#btnSaveMapping').prop('disabled', mapped === 0);
    }
}

// === Auto Match ===
function autoMatchColumns() {
    if (fileColumns.length === 0 || spParams.length === 0) return;
    var matched = 0;
    $('.map-select').each(function () {
        var param = $(this).data('param').replace('@', '').toLowerCase().replace(/_/g, '');
        for (var i = 0; i < fileColumns.length; i++) {
            var col = fileColumns[i].toLowerCase().replace(/_/g, '').replace(/ /g, '');
            if (col === param) { $(this).val(fileColumns[i]); onMapChange(this); matched++; break; }
        }
    });
    if (matched > 0) showAlert('Auto Match', matched + ' column(s) matched automatically!', 'success');
    else showAlert('No Match', 'No matching column names found. Please map manually.', 'info');
}

// === Clear All ===
function clearAllMappings() {
    $('.map-select').val('').removeClass('mapped');
    $('.map-select').closest('tr').find('td:last i').attr('class', 'bi bi-dash-circle text-muted opacity-50');
    updateMappingStats();
}

// === Read Sample File ===
function readSampleFile(input) {
    if (!input.files || !input.files[0]) return;
    var reader = new FileReader();
    reader.onload = function (e) {
        var lines = e.target.result.split('\n').filter(function (l) { return l.trim() !== ""; });
        if (lines.length === 0) { showAlert('Empty', 'The file appears to be empty.', 'warning'); return; }
        fileColumns = lines[0].split('|').map(function (c) { return c.trim(); }).filter(function (c) { return c !== ""; });
        // Parse sample rows (up to 5)
        sampleRows = [];
        for (var i = 1; i < Math.min(lines.length, 6); i++) {
            sampleRows.push(lines[i].split('|').map(function (c) { return c.trim(); }));
        }
        // Show sample preview
        var headHtml = ''; fileColumns.forEach(function (c) { headHtml += '<th class="text-nowrap">' + escHtml(c) + '</th>'; });
        $('#sampleHead').html(headHtml);
        var bodyHtml = ''; sampleRows.forEach(function (row) {
            bodyHtml += '<tr>'; row.forEach(function (cell) { bodyHtml += '<td class="text-nowrap">' + escHtml(cell) + '</td>'; }); bodyHtml += '</tr>';
        });
        $('#sampleBody').html(bodyHtml);
        $('#sampleRowCount').text((lines.length - 1) + ' total rows');
        $('#samplePreview').removeClass('d-none');
        // Re-render mapping table with column options
        if (spParams.length > 0) renderMappingTable();
        $('#btnAutoMatch').prop('disabled', spParams.length === 0);
    };
    reader.readAsText(input.files[0]);
}

// === No SP UI ===
function showNoSPUI(spName, configId) {
    var displayName = (!spName || spName.trim() === "") ? "—" : spName;
    var html = '<div class="text-center py-5"><div class="sp-gen-card card border-0 shadow rounded-4 p-5" style="background:var(--bg-card);">';
    html += '<i class="bi bi-database-exclamation fs-1 text-warning mb-3 d-block"></i>';
    html += '<h5 class="fw-bold">Stored Procedure Not Found</h5>';
    html += '<p class="text-secondary small mb-4">SP "<b>' + escHtml(displayName) + '</b>" is missing or not configured.<br/>Upload a sample TXT, then generate and execute the SP automatically.</p>';
    // Step indicators
    html += '<div class="row g-3 text-start mb-4">';
    html += '<div class="col-4"><div class="p-3 rounded-3" style="background:var(--table-header);"><div class="fw-bold small text-primary mb-1"><i class="bi bi-1-circle me-1"></i>Upload</div><div class="text-muted" style="font-size:0.75rem;">Upload a sample TXT file</div></div></div>';
    html += '<div class="col-4"><div class="p-3 rounded-3" style="background:var(--table-header);"><div class="fw-bold small text-primary mb-1"><i class="bi bi-2-circle me-1"></i>Generate</div><div class="text-muted" style="font-size:0.75rem;">Auto-generate SP script</div></div></div>';
    html += '<div class="col-4"><div class="p-3 rounded-3" style="background:var(--table-header);"><div class="fw-bold small text-primary mb-1"><i class="bi bi-3-circle me-1"></i>Execute</div><div class="text-muted" style="font-size:0.75rem;">Create in DB & map</div></div></div>';
    html += '</div>';
    html += '<button type="button" class="btn btn-warning btn-modern px-4 shadow-sm" onclick="generateSPTemplate()"><i class="bi bi-file-earmark-code me-2"></i>Generate SP Script</button>';
    html += '</div></div>';
    $('#mappingContent').html(html);
}

// === Generate SP Template ===
function generateSPTemplate() {
    if (fileColumns.length === 0) { showAlert('Wait', 'Please upload a sample TXT file first!', 'warning'); return; }
    var spName = $('#mapSPName').text().trim();
    if (!spName || spName === '—') {
        Swal.fire({
            title: 'Enter SP Name', input: 'text',
            inputLabel: 'Name for your Stored Procedure:',
            inputPlaceholder: 'e.g., usp_InsertMyData',
            showCancelButton: true, confirmButtonColor: '#0ea5e9',
            didOpen: function () { setTimeout(function () { Swal.getInput().focus(); }, 100); },
            inputValidator: function (v) {
                if (!v || !v.trim()) return 'Required!';
                if (v.includes(' ')) return 'No spaces allowed!';
                if (/[^a-zA-Z0-9_]/.test(v.trim())) return 'Only letters, numbers, underscores!';
            }
        }).then(function (r) {
            if (r.isConfirmed && r.value) { spName = r.value.trim(); $('#mapSPName').text(spName); showGeneratedSQL(spName); }
        });
    } else { showGeneratedSQL(spName); }
}

function showGeneratedSQL(spName) {
    var sql = 'CREATE PROCEDURE [dbo].[' + spName + ']\n';
    fileColumns.forEach(function (col, i) {
        var pn = col.replace(/ /g, '_');
        
        // Guess data type based on sampleRows
        var bestSample = "";
        for (var r = 0; r < sampleRows.length; r++) {
            if (sampleRows[r][i] && sampleRows[r][i].trim() !== "") {
                bestSample = sampleRows[r][i].trim();
                break;
            }
        }
        
        var dataType = guessJSType(bestSample);
        sql += '    @' + pn + ' ' + dataType + (i < fileColumns.length - 1 ? ',' : '') + '\n';
    });
    sql += 'AS\nBEGIN\n    SET NOCOUNT ON;\n    -- Auto-generated by Ingestion System\nEND';

    Swal.fire({
        title: '<strong>Generated SP Script</strong>', icon: 'info',
        html: '<p class="small text-start text-muted mb-2">Target: <b>' + spName + '</b> in <b>' + (currentTargetDb || 'Default DB') + '</b></p>' +
              '<textarea id="genSQL" class="form-control font-monospace small" style="height:220px;background:#1e293b;color:#10b981;border:none;padding:12px;" readonly>' + sql + '</textarea>',
        showCloseButton: true, showDenyButton: true,
        confirmButtonText: '<i class="bi bi-magic me-2"></i>Execute & Create',
        denyButtonText: '<i class="bi bi-clipboard me-2"></i>Copy Only',
        confirmButtonColor: '#0ea5e9', denyButtonColor: '#64748b'
    }).then(function (r) {
        if (r.isConfirmed) executeCreateSP(spName);
        else if (r.isDenied) { navigator.clipboard.writeText(sql); Swal.fire('Copied!', '', 'success'); }
    });
}

// === Execute Create SP + Update Config ===
function executeCreateSP(spName) {
    var configId = parseInt($('#mapConfigID').text());
    Swal.fire({ title: 'Creating SP...', text: 'Please wait...', allowOutsideClick: false, showConfirmButton: false, didOpen: function () { Swal.showLoading(); } });

    $.ajax({
        type: "POST", url: "Maintenance.aspx/CreateSPAndUpdateConfig",
        data: JSON.stringify({ spName: spName, targetDb: currentTargetDb || "", columns: fileColumns.join(','), configId: configId }),
        contentType: "application/json; charset=utf-8", dataType: "json",
        success: function (r) {
            Swal.close();
            var res = r.d;
            if (res.success) {
                showAlert('Success', res.message, 'success');
                $('#mapSPName').text(spName);
                // Reload SP params to show mapping table
                loadSPParameters(spName, currentTargetDb, configId);
            } else { showAlert('Error', res.message, 'error'); }
        },
        error: function (xhr) {
            Swal.close();
            var msg = 'Request failed';
            try { msg = JSON.parse(xhr.responseText).Message || msg; } catch (e) { }
            showAlert('Error', msg, 'error');
        }
    });
}

// === Save Mapping ===
function saveMapping() {
    var configId = parseInt($('#mapConfigID').text());
    var mappings = [];
    $('.map-select').each(function () {
        if ($(this).val()) mappings.push({ SourceColumn: $(this).val(), TargetParameter: $(this).data('param') });
    });
    if (mappings.length === 0) { showAlert('Wait', 'No mapping configured.', 'warning'); return; }

    $.ajax({
        type: "POST", url: "Maintenance.aspx/SaveMapping",
        data: JSON.stringify({ configId: configId, mappings: mappings }),
        contentType: "application/json; charset=utf-8", dataType: "json",
        success: function (r) {
            if (r.d) { showAlert('Success', 'Mapping saved! (' + mappings.length + ' mappings)', 'success'); mappingModal.hide(); }
            else showAlert('Error', 'Failed to save.', 'error');
        },
        error: function () { showAlert('Error', 'Failed to save mapping.', 'error'); }
    });
}

// === Helpers ===
function escHtml(s) { if (!s) return ''; var d = document.createElement('div'); d.textContent = s; return d.innerHTML; }

function guessJSType(sample) {
    if (!sample || sample.trim() === "") return "VARCHAR(500)";
    sample = sample.trim();

    // Check Numeric
    if (!isNaN(sample) && !isNaN(parseFloat(sample))) {
        if (sample.indexOf('.') > -1) return "DECIMAL(18, 4)";
        return "INT";
    }

    // Check Date (Simple check)
    var dateRegex = /^\d{4}-\d{2}-\d{2}/; // basic YYYY-MM-DD
    if (dateRegex.test(sample) || !isNaN(Date.parse(sample))) {
        return "DATETIME";
    }

    return "VARCHAR(500)";
}
