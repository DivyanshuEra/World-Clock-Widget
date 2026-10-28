using System;
using System.Diagnostics;
using System.Windows;

namespace WorldClock
{
    public static class Program
    {
        [STAThread]
        public static void Main(string[] args)
        {
            // 1. Kill any existing instances of WorldClock as requested by the user
            try
            {
                int currentId = Environment.ProcessId;
                string currentName = Process.GetCurrentProcess().ProcessName;

                foreach (var p in Process.GetProcessesByName(currentName))
                {
                    if (p.Id != currentId)
                    {
                        try
                        {
                            p.Kill();
                            p.WaitForExit(1000);
                        }
                        catch { }
                    }
                }
            }
            catch { }

            // 2. Start WPF Application and run MainWindow directly
            try
            {
                var app = new Application();
                var mainWindow = new MainWindow();
                app.Run(mainWindow);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.ToString(), "World Clock Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
    }
}
