// ===== Mapping Modal Logic =====
let mappingModal;
let currentTargetDb = "";
let fileColumns = [];     // columns parsed from uploaded TXT (if any)
let spParams = [];        // SP parameters loaded from server

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
    document.getElementById('mappingStats').classList.add('d-none');
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

// === No SP UI ===
function showNoSPUI(spName, configId) {
    var displayName = (!spName || spName.trim() === "") ? "—" : spName;
    var html = '<div class="text-center py-5"><div class="sp-gen-card card border-0 shadow rounded-4 p-5" style="background:var(--bg-card);">';
    html += '<i class="bi bi-database-exclamation fs-1 text-warning mb-3 d-block"></i>';
    html += '<h5 class="fw-bold">Stored Procedure Not Found</h5>';
    html += '<p class="text-secondary small mb-0">SP "<b>' + escHtml(displayName) + '</b>" is missing or not configured.<br/>Please ensure the SP exists in the target database.</p>';
    html += '</div></div>';
    $('#mappingContent').html(html);
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

function escHtml(s) { if (!s) return ''; var d = document.createElement('div'); d.textContent = s; return d.innerHTML; }
