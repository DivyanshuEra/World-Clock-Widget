using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.Json;

namespace WorldClock
{
    public class LocationPreset
    {
        public string Country { get; set; } = "";
        public string City { get; set; } = "";
        public string Flag { get; set; } = "🌐";
        public string TimeZone { get; set; } = "+00:00";
        public string Code { get; set; } = "UTC";
        public List<string> Keywords { get; set; } = new List<string>();
    }

    public static class ClockHelper
    {
        private static string? _storageFile;
        public static string StorageFile
        {
            get
            {
                if (_storageFile == null)
                {
                    _storageFile = ResolveStoragePath();
                }
                return _storageFile;
            }
        }

        private static string ResolveStoragePath()
        {
            try
            {
                string baseDir = AppDomain.CurrentDomain.BaseDirectory;
                string localFile = Path.Combine(baseDir, "clocks.json");

                // If clocks.json already exists next to .exe, always use it
                if (File.Exists(localFile))
                {
                    return localFile;
                }

                // Check if directory is writable (portable mode)
                string testFile = Path.Combine(baseDir, $".perm_test_{Guid.NewGuid()}");
                File.WriteAllText(testFile, "ok");
                File.Delete(testFile);
                return localFile;
            }
            catch
            {
                // Fallback to %LocalAppData% if baseDir is protected/read-only
                string appData = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "WorldClockWidget");
                Directory.CreateDirectory(appData);
                return Path.Combine(appData, "clocks.json");
            }
        }

        // Comprehensive Global Presets Database
        public static readonly List<LocationPreset> Presets = new List<LocationPreset>
        {
            new LocationPreset { Country = "India", City = "New Delhi", Flag = "🇮🇳", TimeZone = "India Standard Time", Code = "IST", Keywords = new() { "india", "delhi", "new delhi", "mumbai", "bangalore", "kolkata", "chennai", "hyderabad", "bharat" } },
            new LocationPreset { Country = "USA", City = "New York", Flag = "🇺🇸", TimeZone = "Eastern Standard Time", Code = "EDT/EST", Keywords = new() { "usa", "america", "united states", "new york", "nyc", "washington", "boston", "miami" } },
            new LocationPreset { Country = "USA (West)", City = "Los Angeles", Flag = "🇺🇸", TimeZone = "Pacific Standard Time", Code = "PDT/PST", Keywords = new() { "los angeles", "california", "san francisco", "seattle", "vegas", "las vegas" } },
            new LocationPreset { Country = "USA (Central)", City = "Chicago", Flag = "🇺🇸", TimeZone = "Central Standard Time", Code = "CDT/CST", Keywords = new() { "chicago", "texas", "dallas", "houston", "austin" } },
            new LocationPreset { Country = "UK", City = "London", Flag = "🇬🇧", TimeZone = "GMT Standard Time", Code = "GMT/BST", Keywords = new() { "uk", "united kingdom", "britain", "england", "london", "manchester", "birmingham", "edinburgh" } },
            new LocationPreset { Country = "UAE", City = "Dubai", Flag = "🇦🇪", TimeZone = "Arabian Standard Time", Code = "GST", Keywords = new() { "uae", "dubai", "abu dhabi", "sharjah", "emirates", "united arab emirates" } },
            new LocationPreset { Country = "Japan", City = "Tokyo", Flag = "🇯🇵", TimeZone = "Tokyo Standard Time", Code = "JST", Keywords = new() { "japan", "tokyo", "osaka", "kyoto", "yokohama" } },
            new LocationPreset { Country = "Australia", City = "Sydney", Flag = "🇦🇺", TimeZone = "AUS Eastern Standard Time", Code = "AEST", Keywords = new() { "australia", "sydney", "melbourne", "brisbane", "canberra" } },
            new LocationPreset { Country = "Australia (West)", City = "Perth", Flag = "🇦🇺", TimeZone = "W. Australia Standard Time", Code = "AWST", Keywords = new() { "perth" } },
            new LocationPreset { Country = "Canada", City = "Toronto", Flag = "🇨🇦", TimeZone = "Eastern Standard Time", Code = "EDT/EST", Keywords = new() { "canada", "toronto", "montreal", "ottawa" } },
            new LocationPreset { Country = "Canada (West)", City = "Vancouver", Flag = "🇨🇦", TimeZone = "Pacific Standard Time", Code = "PDT/PST", Keywords = new() { "vancouver" } },
            new LocationPreset { Country = "Germany", City = "Berlin", Flag = "🇩🇪", TimeZone = "W. Europe Standard Time", Code = "CET/CEST", Keywords = new() { "germany", "berlin", "munich", "frankfurt", "hamburg", "deutschland" } },
            new LocationPreset { Country = "France", City = "Paris", Flag = "🇫🇷", TimeZone = "Romance Standard Time", Code = "CET/CEST", Keywords = new() { "france", "paris", "marseille", "lyon" } },
            new LocationPreset { Country = "Singapore", City = "Singapore", Flag = "🇸🇬", TimeZone = "Singapore Standard Time", Code = "SGT", Keywords = new() { "singapore" } },
            new LocationPreset { Country = "China", City = "Beijing", Flag = "🇨🇳", TimeZone = "China Standard Time", Code = "CST", Keywords = new() { "china", "beijing", "shanghai", "shenzhen", "guangzhou" } },
            new LocationPreset { Country = "Hong Kong", City = "Hong Kong", Flag = "🇭🇰", TimeZone = "China Standard Time", Code = "HKT", Keywords = new() { "hong kong" } },
            new LocationPreset { Country = "South Korea", City = "Seoul", Flag = "🇰🇷", TimeZone = "Korea Standard Time", Code = "KST", Keywords = new() { "korea", "south korea", "seoul", "busan" } },
            new LocationPreset { Country = "Saudi Arabia", City = "Riyadh", Flag = "🇸🇦", TimeZone = "Arab Standard Time", Code = "AST", Keywords = new() { "saudi", "saudi arabia", "riyadh", "jeddah", "mecca" } },
            new LocationPreset { Country = "Qatar", City = "Doha", Flag = "🇶🇦", TimeZone = "Arab Standard Time", Code = "AST", Keywords = new() { "qatar", "doha" } },
            new LocationPreset { Country = "Kuwait", City = "Kuwait City", Flag = "🇰🇼", TimeZone = "Arab Standard Time", Code = "AST", Keywords = new() { "kuwait" } },
            new LocationPreset { Country = "Oman", City = "Muscat", Flag = "🇴🇲", TimeZone = "Arabian Standard Time", Code = "GST", Keywords = new() { "oman", "muscat" } },
            new LocationPreset { Country = "Russia", City = "Moscow", Flag = "🇷🇺", TimeZone = "Russian Standard Time", Code = "MSK", Keywords = new() { "russia", "moscow", "saint petersburg" } },
            new LocationPreset { Country = "Italy", City = "Rome", Flag = "🇮🇹", TimeZone = "W. Europe Standard Time", Code = "CET/CEST", Keywords = new() { "italy", "rome", "milan", "venice", "italia" } },
            new LocationPreset { Country = "Spain", City = "Madrid", Flag = "🇪🇸", TimeZone = "Romance Standard Time", Code = "CET/CEST", Keywords = new() { "spain", "madrid", "barcelona", "espana" } },
            new LocationPreset { Country = "Netherlands", City = "Amsterdam", Flag = "🇳🇱", TimeZone = "W. Europe Standard Time", Code = "CET/CEST", Keywords = new() { "netherlands", "holland", "amsterdam" } },
            new LocationPreset { Country = "Switzerland", City = "Zurich", Flag = "🇨🇭", TimeZone = "W. Europe Standard Time", Code = "CET/CEST", Keywords = new() { "switzerland", "zurich", "geneva", "bern" } },
            new LocationPreset { Country = "New Zealand", City = "Auckland", Flag = "🇳🇿", TimeZone = "New Zealand Standard Time", Code = "NZST", Keywords = new() { "new zealand", "auckland", "wellington" } },
            new LocationPreset { Country = "Pakistan", City = "Islamabad", Flag = "🇵🇰", TimeZone = "Pakistan Standard Time", Code = "PKT", Keywords = new() { "pakistan", "islamabad", "karachi", "lahore" } },
            new LocationPreset { Country = "Bangladesh", City = "Dhaka", Flag = "🇧🇩", TimeZone = "Bangladesh Standard Time", Code = "BST", Keywords = new() { "bangladesh", "dhaka" } },
            new LocationPreset { Country = "Nepal", City = "Kathmandu", Flag = "🇳🇵", TimeZone = "Nepal Standard Time", Code = "NPT", Keywords = new() { "nepal", "kathmandu" } },
            new LocationPreset { Country = "Sri Lanka", City = "Colombo", Flag = "🇱🇰", TimeZone = "Sri Lanka Standard Time", Code = "IST", Keywords = new() { "sri lanka", "colombo" } },
            new LocationPreset { Country = "Turkey", City = "Istanbul", Flag = "🇹🇷", TimeZone = "Turkey Standard Time", Code = "TRT", Keywords = new() { "turkey", "istanbul", "ankara", "turkiye" } },
            new LocationPreset { Country = "South Africa", City = "Johannesburg", Flag = "🇿🇦", TimeZone = "South Africa Standard Time", Code = "SAST", Keywords = new() { "south africa", "johannesburg", "cape town" } },
            new LocationPreset { Country = "Brazil", City = "Sao Paulo", Flag = "🇧🇷", TimeZone = "E. South America Standard Time", Code = "BRT", Keywords = new() { "brazil", "sao paulo", "rio", "rio de janeiro" } },
            new LocationPreset { Country = "Argentina", City = "Buenos Aires", Flag = "🇦🇷", TimeZone = "Argentina Standard Time", Code = "ART", Keywords = new() { "argentina", "buenos aires" } },
            new LocationPreset { Country = "Mexico", City = "Mexico City", Flag = "🇲🇽", TimeZone = "Central Standard Time (Mexico)", Code = "CST", Keywords = new() { "mexico", "mexico city" } },
            new LocationPreset { Country = "Egypt", City = "Cairo", Flag = "🇪🇬", TimeZone = "Egypt Standard Time", Code = "EET", Keywords = new() { "egypt", "cairo" } },
            new LocationPreset { Country = "Thailand", City = "Bangkok", Flag = "🇹🇭", TimeZone = "SE Asia Standard Time", Code = "ICT", Keywords = new() { "thailand", "bangkok" } },
            new LocationPreset { Country = "Malaysia", City = "Kuala Lumpur", Flag = "🇲🇾", TimeZone = "Singapore Standard Time", Code = "MYT", Keywords = new() { "malaysia", "kuala lumpur" } },
            new LocationPreset { Country = "Indonesia", City = "Jakarta", Flag = "🇮🇩", TimeZone = "SE Asia Standard Time", Code = "WIB", Keywords = new() { "indonesia", "jakarta", "bali" } },
            new LocationPreset { Country = "Vietnam", City = "Hanoi", Flag = "🇻🇳", TimeZone = "SE Asia Standard Time", Code = "ICT", Keywords = new() { "vietnam", "hanoi" } },
            new LocationPreset { Country = "Philippines", City = "Manila", Flag = "🇵🇭", TimeZone = "Singapore Standard Time", Code = "PHT", Keywords = new() { "philippines", "manila" } },
            new LocationPreset { Country = "Ireland", City = "Dublin", Flag = "🇮🇪", TimeZone = "GMT Standard Time", Code = "GMT/IST", Keywords = new() { "ireland", "dublin" } },
            new LocationPreset { Country = "Sweden", City = "Stockholm", Flag = "🇸🇪", TimeZone = "W. Europe Standard Time", Code = "CET/CEST", Keywords = new() { "sweden", "stockholm" } },
            new LocationPreset { Country = "Norway", City = "Oslo", Flag = "🇳🇴", TimeZone = "W. Europe Standard Time", Code = "CET/CEST", Keywords = new() { "norway", "oslo" } },
            new LocationPreset { Country = "Denmark", City = "Copenhagen", Flag = "🇩🇰", TimeZone = "Romance Standard Time", Code = "CET/CEST", Keywords = new() { "denmark", "copenhagen" } },
            new LocationPreset { Country = "Poland", City = "Warsaw", Flag = "🇵🇱", TimeZone = "Central European Standard Time", Code = "CET/CEST", Keywords = new() { "poland", "warsaw" } },
            new LocationPreset { Country = "Portugal", City = "Lisbon", Flag = "🇵🇹", TimeZone = "GMT Standard Time", Code = "WET/WEST", Keywords = new() { "portugal", "lisbon" } },
            new LocationPreset { Country = "Greece", City = "Athens", Flag = "🇬🇷", TimeZone = "GTB Standard Time", Code = "EET/EEST", Keywords = new() { "greece", "athens" } },
            new LocationPreset { Country = "Austria", City = "Vienna", Flag = "🇦🇹", TimeZone = "W. Europe Standard Time", Code = "CET/CEST", Keywords = new() { "austria", "vienna" } },
            new LocationPreset { Country = "Belgium", City = "Brussels", Flag = "🇧🇪", TimeZone = "Romance Standard Time", Code = "CET/CEST", Keywords = new() { "belgium", "brussels" } }
        };

        // ACCURATE & SMART SEARCH: Multi-Country (e.g. Turkey/Qatar) and single country support
        public static LocationPreset? FindPreset(string input)
        {
            if (string.IsNullOrWhiteSpace(input)) return null;
            string clean = input.Trim().ToLowerInvariant();

            // Ignore 1-letter typing to avoid premature false matches
            if (clean.Length < 2) return null;

            // Check if input contains multi-country delimiters: '/', ',', '&', '+'
            char[] delimiters = new[] { '/', ',', '&', '+' };
            if (input.IndexOfAny(delimiters) >= 0)
            {
                var parts = input.Split(delimiters, StringSplitOptions.RemoveEmptyEntries)
                                 .Select(p => p.Trim())
                                 .Where(p => p.Length >= 2)
                                 .ToList();

                if (parts.Count > 0)
                {
                    List<LocationPreset> matchedPresets = new List<LocationPreset>();
                    foreach (var part in parts)
                    {
                        var singleMatch = FindSinglePreset(part);
                        if (singleMatch != null && !matchedPresets.Any(m => m.Country.Equals(singleMatch.Country, StringComparison.OrdinalIgnoreCase)))
                        {
                            matchedPresets.Add(singleMatch);
                        }
                    }

                    if (matchedPresets.Count > 0)
                    {
                        var primary = matchedPresets[0];
                        // Combine flags if multiple (e.g. "🇹🇷 🇶🇦")
                        string combinedFlags = string.Join(" ", matchedPresets.Select(m => m.Flag).Distinct());
                        string combinedCities = string.Join(" / ", matchedPresets.Select(m => m.City).Distinct());
                        string combinedCodes = string.Join("/", matchedPresets.Select(m => m.Code).Distinct());

                        return new LocationPreset
                        {
                            Country = input.Trim(),
                            City = combinedCities,
                            Flag = combinedFlags,
                            TimeZone = primary.TimeZone,
                            Code = combinedCodes.Length > 8 ? primary.Code : combinedCodes,
                            Keywords = primary.Keywords
                        };
                    }
                }
            }

            return FindSinglePreset(clean);
        }

        private static LocationPreset? FindSinglePreset(string clean)
        {
            clean = clean.Trim().ToLowerInvariant();
            if (clean.Length < 2) return null;

            // 1. Exact match on Country or City
            foreach (var p in Presets)
            {
                if (p.Country.Equals(clean, StringComparison.OrdinalIgnoreCase) ||
                    p.City.Equals(clean, StringComparison.OrdinalIgnoreCase))
                {
                    return p;
                }
            }

            // 2. Exact match on any keyword
            foreach (var p in Presets)
            {
                if (p.Keywords.Any(k => k.Equals(clean, StringComparison.OrdinalIgnoreCase)))
                {
                    return p;
                }
            }

            // 3. StartsWith match (only if at least 3 characters)
            if (clean.Length >= 3)
            {
                foreach (var p in Presets)
                {
                    if (p.Country.ToLowerInvariant().StartsWith(clean) ||
                        p.City.ToLowerInvariant().StartsWith(clean) ||
                        p.Keywords.Any(k => k.StartsWith(clean)))
                    {
                        return p;
                    }
                }
            }

            return null;
        }

        public static List<ClockItem> GetDefaultClocks()
        {
            return new List<ClockItem>
            {
                new ClockItem { Flag = "", Country = "India", City = "New Delhi", TimeZoneInput = "India Standard Time", DisplayCode = "IST" },
                new ClockItem { Flag = "", Country = "USA", City = "New York", TimeZoneInput = "Eastern Standard Time", DisplayCode = "EDT" },
                new ClockItem { Flag = "", Country = "UK", City = "London", TimeZoneInput = "GMT Standard Time", DisplayCode = "GMT/BST" },
                new ClockItem { Flag = "", Country = "UAE", City = "Dubai", TimeZoneInput = "Arabian Standard Time", DisplayCode = "GST" },
                new ClockItem { Flag = "", Country = "Japan", City = "Tokyo", TimeZoneInput = "Tokyo Standard Time", DisplayCode = "JST" }
            };
        }

        public static List<ClockItem> LoadClocks()
        {
            try
            {
                if (File.Exists(StorageFile))
                {
                    string json = File.ReadAllText(StorageFile);
                    var items = JsonSerializer.Deserialize<List<ClockItem>>(json);
                    if (items != null && items.Count > 0)
                    {
                        return items;
                    }
                }
            }
            catch { }
            return GetDefaultClocks();
        }

        public static void SaveClocks(IEnumerable<ClockItem> clocks)
        {
            try
            {
                var list = new List<ClockItem>();
                foreach (var c in clocks)
                {
                    list.Add(new ClockItem
                    {
                        Id = c.Id,
                        Flag = c.Flag,
                        Country = c.Country,
                        City = c.City,
                        TimeZoneInput = c.TimeZoneInput,
                        DisplayCode = c.DisplayCode
                    });
                }
                string json = JsonSerializer.Serialize(list, new JsonSerializerOptions { WriteIndented = true });
                File.WriteAllText(StorageFile, json);
            }
            catch { }
        }

        // Return Live Time + Date with CLEAR UTC / GMT Offset!
        public static (string time, string date) GetCurrentTimeAndDate(ClockItem item)
        {
            DateTime utcNow = DateTime.UtcNow;
            var (local, offsetStr) = ParseToLocalTimeWithOffset(utcNow, item.TimeZoneInput, item.Country, item.City);

            string timeStr = local.ToString("hh:mm:ss tt");

            // Format: Mon, 26 Oct  •  UTC+5:30  •  IST
            string codePart = string.IsNullOrWhiteSpace(item.DisplayCode) ? "" : $" • {item.DisplayCode}";
            string dateStr = $"{local:ddd, dd MMM} • {offsetStr}{codePart}";

            return (timeStr, dateStr);
        }

        public static (DateTime local, string offsetStr) ParseToLocalTimeWithOffset(DateTime utcNow, string input, string countryHint = "", string cityHint = "")
        {
            // 1. Check smart presets
            var preset = FindPreset(input);
            if (preset == null && !string.IsNullOrWhiteSpace(countryHint))
            {
                preset = FindPreset(countryHint);
            }
            if (preset == null && !string.IsNullOrWhiteSpace(cityHint))
            {
                preset = FindPreset(cityHint);
            }
            if (preset != null)
            {
                try
                {
                    var tz = TimeZoneInfo.FindSystemTimeZoneById(preset.TimeZone);
                    DateTime loc = TimeZoneInfo.ConvertTimeFromUtc(utcNow, tz);
                    TimeSpan off = tz.GetUtcOffset(utcNow);
                    return (loc, FormatUtcOffset(off));
                }
                catch { }
            }

            if (!string.IsNullOrWhiteSpace(input))
            {
                string raw = input.Trim();

                // 2. Try Windows System Time Zone ID
                try
                {
                    var tz = TimeZoneInfo.FindSystemTimeZoneById(raw);
                    DateTime loc = TimeZoneInfo.ConvertTimeFromUtc(utcNow, tz);
                    TimeSpan off = tz.GetUtcOffset(utcNow);
                    return (loc, FormatUtcOffset(off));
                }
                catch { }

                // 3. Try offset format e.g. "+5:30", "-4", "UTC+5:30"
                string clean = raw.ToUpper().Replace("UTC", "").Replace("GMT", "").Trim();
                if (TimeSpan.TryParse(clean, out TimeSpan ts))
                {
                    return (utcNow.Add(ts), FormatUtcOffset(ts));
                }
                if (double.TryParse(clean, System.Globalization.NumberStyles.Float, System.Globalization.CultureInfo.InvariantCulture, out double hours))
                {
                    TimeSpan off = TimeSpan.FromHours(hours);
                    return (utcNow.Add(off), FormatUtcOffset(off));
                }
            }

            return (utcNow, "UTC+0");
        }

        public static string FormatUtcOffset(TimeSpan offset)
        {
            string sign = offset.TotalMinutes >= 0 ? "+" : "-";
            int h = Math.Abs(offset.Hours);
            int m = Math.Abs(offset.Minutes);
            return m > 0 ? $"UTC{sign}{h}:{m:D2}" : $"UTC{sign}{h}";
        }
    }
}
