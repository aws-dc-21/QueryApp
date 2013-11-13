class RunQueriesController < ApplicationController
  layout false

  def new
    @run_query = RunQuery.new
  end

  def create
    @run_query = RunQuery.new(run_query_params)

    if @run_query.valid?
      @query_runner = QueryRunner.new(@run_query.sql)

      case params[:commit]
      when 'Display Results'
        render :action => 'create'
      when 'Download CSV'
        send_data @query_runner.to_csv, :filename => 'data.csv'
      end
    else
      render :action => 'new'
    end
  end

  private

  def run_query_params
    params.require(:run_query).permit(:sql)
  end
end
