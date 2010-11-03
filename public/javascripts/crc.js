var crc = function () {
 
  var updateCrcStatus = function (status) {
    var $current = $("#crc-status :visible");
    if ($current.attr("id") != "crc-" + status) {
      $current.fadeOut(function () {
        $("#crc-" + status).fadeIn();
      });
    }
  };
 
  return {
 
    launch: function () {
      crc.createCalcTriggers();
      crc.createHhmrTrigger();
      crc.initTabs();
    },
    
    initTabs : function () {
      $(".tab").click(function () {
        $(".tab-content").hide();
        $(".tab").removeClass("selected");
        $(this).addClass("selected");
        var visId = $(this).attr("id").split("-")[0];
        $("#" + visId).show();
      });
      
      $("#league-tab").click(function () {
        $("#league").load("/calculator/league_table");
      });

      $("#report-tab").click(function () {
        $("#report").load("/calculator/web_report");
      });
    },
           
    createHhmrTrigger : function () {
      $("#hhmr").click(function () {
        $.ajax({
          url: "/calculator/hhmr",
          type: "POST",
          data: {hhmr: $(this).is(":checked")},
          dataType: "json",
          success: function (res) {
            updateCrcStatus(res.crc_status);
          },
          error: function () {
            updateCrcStatus("unknown");
          }
        });        
      });
    },
   
    createCalcTriggers: function () {       
      var calcTimer = null;       
     
      var invokeCalc = function (e) {
        // Allow users to tab around without automatically calculating
        // Respectively ignore:
        // tab, tab, shift, alt, cmd, cmd
        var ignore = $.inArray(e.which, [0, 9, 16, 18, 91, 224]) >= 0;
        if (!ignore) {
          var input = this;
          window.clearTimeout(calcTimer);
          calcTimer = window.setTimeout(function () {
            crc.calcCo2.apply(input);
          }, 500);
        }
      };
     
      $("#crc-data input").keyup(invokeCalc);
      $("#crc-data input").keydown(invokeCalc);
      $("#crc-data input").keypress(invokeCalc);
    },

    calcCo2: function () {      
      var sr = null;
      
      var success = function (res) {
        $(sr + "-co2").text(res.co2);
        $(sr + "-cost").text(res.cost);
        $("#total-co2").text(res.total_co2).removeClass("calc-error");
        $("#total-cost").text(res.total_cost).removeClass("calc-error");
        
        $input.removeClass("calculating").removeClass("calc-error");
        updateCrcStatus(res.crc_status);
      };
      
      var error = function (res) {
        $input.removeClass("calculating").addClass("calc-error");
        $(sr + "-co2").text("0");
        $(sr + "-cost").text("0");

        $("#total-co2").addClass("calc-error");
        $("#total-cost").addClass("calc-error");

        updateCrcStatus("unknown");
      }
      
      var $input = $(this);
      var val = $input.val();
      val = $.trim(val) == "" ? "0" : val
            
      if (!val.match(/^[0-9]+$/)) {
        error();
      } else {
        $input.addClass("calculating");
        sr = "#" + $input.attr("id");

        var unit = $(sr + "-unit").text();
        var drill = $input.attr("data-drill");
        
        $.ajax({
          url: "/calculator/co2",
          type: "POST",
          data: {val:val, drill:drill, unit:unit},
          dataType: "json",
          success: success,
          error: error
        });        
      }
   }
         
 };
       
}();

$(document).ready(crc.launch);
