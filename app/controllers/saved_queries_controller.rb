class SavedQueriesController < ApplicationController
  before_action :set_saved_query, only: [:show, :edit, :update, :destroy]

  def index
    @saved_queries = SavedQuery.all
  end

  def show
    @query_runner = QueryRunner.new(@saved_query.sql)
  end

  def new
    @saved_query = SavedQuery.new
  end

  def edit
  end

  def create
    @saved_query = SavedQuery.new(saved_query_params)

    if @saved_query.save
      redirect_to @saved_query, notice: 'Saved query was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    if @saved_query.update(saved_query_params)
      redirect_to @saved_query, notice: 'Saved query was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @saved_query.destroy
    redirect_to saved_queries_url
  end

  private

  def set_saved_query
    @saved_query = SavedQuery.find(params[:id])
  end

  def saved_query_params
    params.require(:saved_query).permit(:name, :description, :sql)
  end
end
