using System;
using System.Collections.Generic;
using System.Text;

namespace Fred.IronScripter2018
{
    /// <summary>
    /// Information on a computer
    /// </summary>
    [Serializable]
    public class SystemInformation
    {
        /// <summary>
        /// The name of the computer it is installed on.
        /// </summary>
        public string ComputerName;

        /// <summary>
        /// Name of the OS
        /// </summary>
        public string Name;

        /// <summary>
        /// Version of the OS
        /// </summary>
        public Version Version;

        /// <summary>
        /// Installed Service Pack
        /// </summary>
        public string ServicePack;

        /// <summary>
        /// Manufacturer of the OS
        /// </summary>
        public string Manufacturer;

        /// <summary>
        /// Path where windows lies.
        /// </summary>
        public string WindowsDirectory;

        /// <summary>
        /// What locale the system is running under
        /// </summary>
        public string Locale;

        /// <summary>
        /// The amount of physical memory still available
        /// </summary>
        public long FreePhysicalMemory;

        /// <summary>
        /// The total virtual memory available
        /// </summary>
        public long VirtualMemory;

        /// <summary>
        /// The free amount of virtual memory still available
        /// </summary>
        public long FreeVirtualMemory;

        /// <summary>
        /// The disks installed on the system.
        /// </summary>
        public List<DiskInfo> Disks = new List<DiskInfo>();
    }
}
