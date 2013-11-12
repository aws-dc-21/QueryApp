class RunQueriesController < ApplicationController
  before_action :set_run_query, only: [:show, :edit, :update, :destroy]

  # GET /run_queries
  # GET /run_queries.json
  def index
    @run_queries = RunQuery.all
  end

  # GET /run_queries/1
  # GET /run_queries/1.json
  def show
  end

  # GET /run_queries/new
  def new
    @run_query = RunQuery.new
  end

  # GET /run_queries/1/edit
  def edit
  end

  # POST /run_queries
  # POST /run_queries.json
  def create
    @run_query = RunQuery.new(run_query_params)

    respond_to do |format|
      if @run_query.save
        format.html { redirect_to @run_query, notice: 'Run query was successfully created.' }
        format.json { render action: 'show', status: :created, location: @run_query }
      else
        format.html { render action: 'new' }
        format.json { render json: @run_query.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /run_queries/1
  # PATCH/PUT /run_queries/1.json
  def update
    respond_to do |format|
      if @run_query.update(run_query_params)
        format.html { redirect_to @run_query, notice: 'Run query was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @run_query.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /run_queries/1
  # DELETE /run_queries/1.json
  def destroy
    @run_query.destroy
    respond_to do |format|
      format.html { redirect_to run_queries_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_run_query
      @run_query = RunQuery.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def run_query_params
      params.require(:run_query).permit(:sql)
    end
end
