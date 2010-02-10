var crcWr = function () {
  
  return {    
    // For storing objects from the server
    data : new Object(),    
    
    launch : function () {
      crcWr.enableOrgNaming();
      crcWr.syncDateFormats();
    },
    
    enableOrgNaming : function () {
      var defaultName = "Your Org Name"; 
            
      $("#org_name").focus(function () {
        var $this = $(this);
        if ($this.val() == defaultName) {
          $this.val("").removeClass("textfield-placeholder");
        }
      });
      
      $("#org_name").blur(function () {
        var $input = $(this);
        var val = $.trim($input.val());
        
        if (val == "" || val == defaultName) {
          $input.val(defaultName).addClass("textfield-placeholder");
        }
      });
    },
    
    syncDateFormats : function () {
      $("#gen_date").change(function () {
        var refDate = crcWr.data.timeFormats[$(this).val()];
        $("#ref_date_vis").text(refDate);
        $("#ref_date").val(refDate);
      });
    }
    
  };
  
}();

$(document).ready(crcWr.launch);
