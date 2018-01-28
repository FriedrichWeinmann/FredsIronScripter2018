using System;

namespace Fred.IronScripter2018
{
    /// <summary>
    /// Class containing information on a monitor
    /// </summary>
    [Serializable]
    public class Monitor
    {
        /// <summary>
        /// The name of the computer
        /// </summary>
        public string ComputerName;

        /// <summary>
        /// The type of the computer
        /// </summary>
        public string ComputerType;

        /// <summary>
        /// The bios serial number, uniquely identifying the hardware
        /// </summary>
        public string ComputerSerial;

        /// <summary>
        /// Monitor serial number
        /// </summary>
        public string MonitorSerial;

        /// <summary>
        /// Monitor model type
        /// </summary>
        public string MonitorType;
    }
}
