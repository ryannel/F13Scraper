//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace StockScraper.Models
{
    using System;
    using System.Collections.Generic;
    
    public partial class Registration
    {
        public int RegistrationId { get; set; }
        public int HedgeFundId { get; set; }
        public int RegistrationAuthorityId { get; set; }
        public string Identifier { get; set; }
    
        public virtual HedgeFund HedgeFund { get; set; }
        public virtual RegistrationAuthority RegistrationAuthority { get; set; }
    }
}
