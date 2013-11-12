class SavedQueriesController < ApplicationController
  before_action :set_saved_query, only: [:show, :edit, :update, :destroy]

  # GET /saved_queries
  # GET /saved_queries.json
  def index
    @saved_queries = SavedQuery.all
  end

  # GET /saved_queries/1
  # GET /saved_queries/1.json
  def show
  end

  # GET /saved_queries/new
  def new
    @saved_query = SavedQuery.new
  end

  # GET /saved_queries/1/edit
  def edit
  end

  # POST /saved_queries
  # POST /saved_queries.json
  def create
    @saved_query = SavedQuery.new(saved_query_params)

    respond_to do |format|
      if @saved_query.save
        format.html { redirect_to @saved_query, notice: 'Saved query was successfully created.' }
        format.json { render action: 'show', status: :created, location: @saved_query }
      else
        format.html { render action: 'new' }
        format.json { render json: @saved_query.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /saved_queries/1
  # PATCH/PUT /saved_queries/1.json
  def update
    respond_to do |format|
      if @saved_query.update(saved_query_params)
        format.html { redirect_to @saved_query, notice: 'Saved query was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @saved_query.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /saved_queries/1
  # DELETE /saved_queries/1.json
  def destroy
    @saved_query.destroy
    respond_to do |format|
      format.html { redirect_to saved_queries_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_saved_query
      @saved_query = SavedQuery.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def saved_query_params
      params.require(:saved_query).permit(:name, :description, :sql)
    end
end
