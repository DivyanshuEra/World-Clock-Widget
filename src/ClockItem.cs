using System;
using System.ComponentModel;
using System.Runtime.CompilerServices;

namespace WorldClock
{
    public class ClockItem : INotifyPropertyChanged
    {
        private string _id = Guid.NewGuid().ToString();
        private string _flag = "🌐";
        private string _country = "Country";
        private string _city = "City";
        private string _timeZoneInput = "+05:30";
        private string _displayCode = "IST";
        private string _currentTime = "--:--:-- --";
        private string _currentDate = "---";
        private bool _isReorderMode = false;

        public string Id
        {
            get => _id;
            set { _id = value; OnPropertyChanged(); }
        }

        public string Flag
        {
            get => _flag;
            set { _flag = value; OnPropertyChanged(); }
        }

        public string Country
        {
            get => _country;
            set { _country = value; OnPropertyChanged(); }
        }

        public string City
        {
            get => _city;
            set { _city = value; OnPropertyChanged(); }
        }

        public string TimeZoneInput
        {
            get => _timeZoneInput;
            set { _timeZoneInput = value; OnPropertyChanged(); }
        }

        public string DisplayCode
        {
            get => _displayCode;
            set { _displayCode = value; OnPropertyChanged(); }
        }

        public string CurrentTime
        {
            get => _currentTime;
            set { _currentTime = value; OnPropertyChanged(); }
        }

        public string CurrentDate
        {
            get => _currentDate;
            set { _currentDate = value; OnPropertyChanged(); }
        }

        public bool IsReorderMode
        {
            get => _isReorderMode;
            set { _isReorderMode = value; OnPropertyChanged(); }
        }

        public event PropertyChangedEventHandler? PropertyChanged;
        protected void OnPropertyChanged([CallerMemberName] string? name = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(name));
        }

        public ClockItem Clone()
        {
            return new ClockItem
            {
                Id = this.Id,
                Flag = this.Flag,
                Country = this.Country,
                City = this.City,
                TimeZoneInput = this.TimeZoneInput,
                DisplayCode = this.DisplayCode
            };
        }
    }
}
