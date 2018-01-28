using System;

namespace Fred.IronScripter2018
{
    /// <summary>
    /// Class containing information on a disk
    /// </summary>
    [Serializable]
    public class DiskInfo
    {
        /// <summary>
        /// The name of the computer the disk is installed on
        /// </summary>
        public string ComputerName;

        /// <summary>
        /// The ID of the drive
        /// </summary>
        public string Drive;

        /// <summary>
        /// What kind of drive is it?
        /// </summary>
        public string DriveType;

        /// <summary>
        /// What is the maximum capacity of this drive
        /// </summary>
        public long Size;

        /// <summary>
        /// How much free space is still available?
        /// </summary>
        public long FreeSpace;

        /// <summary>
        /// How much percent of the space is still in use?
        /// </summary>
        public double UsedPercent
        {
            get
            {
                return (Size - FreeSpace) / Size * 100;
            }
            set
            {
                // Needs to not throw an exception on set for the type serializer
            }
        }

        /// <summary>
        /// Is the disk compressed?
        /// </summary>
        public bool Compressed;

        /// <summary>
        /// Creates the default drive display when as a property on another object
        /// </summary>
        /// <returns>The string representation of the drive</returns>
        public override string ToString()
        {
            return String.Format("{0} : {1}%", Drive, Math.Round(UsedPercent, 2));
        }
    }
}
