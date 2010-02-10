class Pdf::Report
  
  # Required for number formatting
  include ActionView::Helpers::NumberHelper
  include CalculatorHelper
  
  def initialize
    @p = Prawn::Document.new
  end

  def generate org_name, gen_date, ref_date, rank, total, breakdown    
    add_footer
    
    @p.bounding_box([50, @p.bounds.height - 10], 
        :width => (@p.bounds.width - 100), :height => (@p.bounds.height - 35)) do      
      @table_width = @p.bounds.width            
      add_overview org_name, gen_date, ref_date, rank
      add_totals total
      add_breakdown breakdown
    end
    
    @p
  end
  
  def add_footer
    @p.footer [@p.margin_box.left, @p.margin_box.bottom + 25] do
      @p.image "#{RAILS_ROOT}/public/images/powered_by_amee.png", :position => :right
    end
  end  
  
  def add_overview org_name, gen_date, ref_date, rank
    @p.font "Helvetica"
    @p.text "Carbon Reduction Commitment Report", :size => 20    
    
    @p.move_down 15
    @p.font "Times-Roman"
    overview = [
      ["Organisation", org_name],
      ["Date generated", gen_date],
      ["Standards reference data", ref_date],
      ["Virtual league table ranking", rank.to_s],
    ]
    @p.table overview,
      :border_style   => :underline_header,
      :position       => :center,
      :width => @table_width,
      :align => {1 => :right}
    @p.move_down 15  
    @p.stroke_horizontal_rule            
  end
  
  def add_totals total
    @p.move_down 15
    @p.font "Helvetica"
    @p.text "Totals", :size => 16  

    @p.font "Times-Roman"
    totals = [
      ["Total tCO2", fmt_no(total.co2)],
      ["Total liability (£)", fmt_no(total.cost)],
    ]
    @p.table totals,
      :border_style   => :underline_header,
      :position       => :center,
      :width => @table_width,
      :align => {1 => :right}
    @p.move_down 15  
    @p.stroke_horizontal_rule    
  end
  
  def add_breakdown breakdown
    @p.move_down 15
    @p.font "Helvetica"
    @p.text "Breakdown", :size => 16    

    @p.font "Times-Roman"
    breakdown = breakdown.map do |e|
      [e.hr_name, fmt_no(e.value), e.unit, fmt_no(e.co2), fmt_no(e.cost)]
    end
    @p.table breakdown,
      :border_style   => :underline_header,
      :position       => :center,
      :headers        => ["Type","Value","Unit", "kgCO2 / yr", "£ / yr"],
      :width => @table_width,
      :align => {1 => :right, 3 => :right, 4 => :right}
    @p.move_down 15
    @p.stroke_horizontal_rule    
  end
    
end
