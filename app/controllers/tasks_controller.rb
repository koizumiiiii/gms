class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy]

  def add_task
    task = Task.new(task_params)

    result = { success: task.save }
    render json: result
  end

  def task_list
"""
    result = {}
    tasks.each do |task|
      month = task.start_at.strftime('%Y/%m')
      if result[month].blank?
        result[month] = []
      end
      result[month] << {
        id: task.id,
        date: task.start_at.day,
        title: task.title
      }
    end
    render json: result
"""
    next_start_at = params[:next_start_at]&.in_time_zone || Time.now
    next_id = params[:next_id].to_i

    tasks = Task.where('(start_at = ? AND id > ?) OR ? < start_at', next_start_at, next_id, next_start_at)
      .order(start_at: :asc, id: :asc)
      .limit(10)

    render json: tasks.to_a
  end

  # GET /tasks
  # GET /tasks.json
  def index
    @tasks = Task.all
  end

  # GET /tasks/1
  # GET /tasks/1.json
  def show
  end

  # GET /tasks/new
  def new
    @task = Task.new
  end

  # GET /tasks/1/edit
  def edit
  end

  # POST /tasks
  # POST /tasks.json
  def create
    @task = Task.new(task_params)

    respond_to do |format|
      if @task.save
        format.html { redirect_to @task, notice: 'Task was successfully created.' }
        format.json { render :show, status: :created, location: @task }
      else
        format.html { render :new }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tasks/1
  # PATCH/PUT /tasks/1.json
  def update
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to @task, notice: 'Task was successfully updated.' }
        format.json { render :show, status: :ok, location: @task }
      else
        format.html { render :edit }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.json
  def destroy
    @task.destroy
    respond_to do |format|
      format.html { redirect_to tasks_url, notice: 'Task was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = Task.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def task_params
      params.require(:task).permit(:title, :detail, :start_at, :weather_infomation, :place, :latitude, :longitude)
    end
end
