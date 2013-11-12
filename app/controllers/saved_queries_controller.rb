class SavedQueriesController < ApplicationController
  before_action :set_saved_query, only: [:show, :edit, :update, :destroy]

  def index
    @saved_queries = SavedQuery.all
  end

  def show
  end

  def new
    @saved_query = SavedQuery.new
  end

  def edit
  end

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

  def destroy
    @saved_query.destroy
    respond_to do |format|
      format.html { redirect_to saved_queries_url }
      format.json { head :no_content }
    end
  end

  private

  def set_saved_query
    @saved_query = SavedQuery.find(params[:id])
  end

  def saved_query_params
    params.require(:saved_query).permit(:name, :description, :sql)
  end
end
