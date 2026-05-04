using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using Newtonsoft.Json;
using System.Data.SqlClient;

namespace Migrasi
{
    public class ConnectionProfile
    {
        public string Id { get; set; }
        public string Name { get; set; }
        public string Server { get; set; }
        public string Database { get; set; }
        public string Username { get; set; }
        public string Password { get; set; }
        public bool IsActive { get; set; }

        [JsonIgnore]
        public string ConnectionString
        {
            get
            {
                SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder();
                builder.DataSource = Server;
                builder.InitialCatalog = Database;
                builder.UserID = Username;
                builder.Password = Password;
                builder.TrustServerCertificate = true; // Often needed for local/dev servers
                return builder.ConnectionString;
            }
        }
    }

    public static class ConnectionHelper
    {
        private static string FilePath
        {
            get
            {
                string root = HttpContext.Current != null 
                    ? HttpContext.Current.Server.MapPath("~/") 
                    : HttpRuntime.AppDomainAppPath;
                return Path.Combine(root, "App_Data", "connections.json");
            }
        }

        public static List<ConnectionProfile> GetProfiles()
        {
            if (!File.Exists(FilePath))
            {
                // Create default from Web.config if file doesn't exist
                var profiles = new List<ConnectionProfile>();
                try
                {
                    string webConfigConn = System.Configuration.ConfigurationManager.ConnectionStrings["SimulasiDB"]?.ConnectionString;
                    if (!string.IsNullOrEmpty(webConfigConn))
                    {
                        var builder = new SqlConnectionStringBuilder(webConfigConn);
                        profiles.Add(new ConnectionProfile
                        {
                            Id = Guid.NewGuid().ToString(),
                            Name = "Default (Web.config)",
                            Server = builder.DataSource,
                            Database = builder.InitialCatalog,
                            Username = builder.UserID,
                            Password = builder.Password,
                            IsActive = true
                        });
                        SaveProfiles(profiles);
                    }
                }
                catch { }
                return profiles;
            }

            string json = File.ReadAllText(FilePath);
            return JsonConvert.DeserializeObject<List<ConnectionProfile>>(json) ?? new List<ConnectionProfile>();
        }

        public static void SaveProfiles(List<ConnectionProfile> profiles)
        {
            string dir = Path.GetDirectoryName(FilePath);
            if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);
            
            string json = JsonConvert.SerializeObject(profiles, Formatting.Indented);
            File.WriteAllText(FilePath, json);
        }

        public static string GetActiveConnectionString()
        {
            var active = GetProfiles().FirstOrDefault(p => p.IsActive);
            if (active != null) return active.ConnectionString;
            
            // Fallback to web.config
            return System.Configuration.ConfigurationManager.ConnectionStrings["SimulasiDB"]?.ConnectionString;
        }

        public static ConnectionProfile GetActiveProfile()
        {
            return GetProfiles().FirstOrDefault(p => p.IsActive);
        }
    }
}
