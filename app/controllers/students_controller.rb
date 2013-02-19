class StudentsController < ApplicationController
  # GET /students
  # GET /students.json
  def index
    @students = Student.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @students }
    end
  end

  # GET /students/1
  # GET /students/1.json
  def show
    @student = Student.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @student }
    end
  end

  # GET /students/new
  # GET /students/new.json
  def new
    @student = Student.new
    @groups = Group.all
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @student }
    end
  end

  # POST /students
  # POST /students.json
  def create
    @student = Student.new(params[:student])
    if @student.group != nil 
      @student.group.students << @student
    end

    respond_to do |format|
      if (@student.group == nil || @student.group.valid?) && @student.valid?
        if @student.group != nil 
          @student.group.save
        end
        @student.save
        format.html { redirect_to @student, notice: 'Student was successfully created.' }
        format.json { render json: @student, status: :created, location: @student }
      else
        @groups = Group.all
        format.html { render action: "new" }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end
  
end
