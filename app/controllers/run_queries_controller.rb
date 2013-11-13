class RunQueriesController < ApplicationController
  layout false

  def new
    @run_query = RunQuery.new
  end

  def create
    @run_query = RunQuery.new(run_query_params)
    saved_query = SavedQuery.where(:sql => run_query_params[:sql]).first
    if saved_query
      SavedQuery.increment_counter(:query_count, saved_query.id)
    end

    if @run_query.valid?
      @query_runner = QueryRunner.new(@run_query.sql)

      case params[:commit]
      when 'Display Results'
        render :action => 'create'
      when 'Download CSV'
        send_data @query_runner.to_csv, :filename => 'data.csv'
      end
    else
      flash[:errors] = @run_query.errors.full_messages
      render :partial => 'errors', :status => 422
    end
  rescue => e
    flash[:errors] = [e.message]
    render :partial => 'errors', :status => 500
  end

  private

  def run_query_params
    params.require(:run_query).permit(:sql)
  end
end
