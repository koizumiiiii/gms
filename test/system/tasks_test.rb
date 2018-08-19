require "application_system_test_case"

class TasksTest < ApplicationSystemTestCase
  setup do
    @task = tasks(:one)
  end

  test "visiting the index" do
    visit tasks_url
    assert_selector "h1", text: "Tasks"
  end

  test "creating a Task" do
    visit tasks_url
    click_on "New Task"

    fill_in "Detail", with: @task.detail
    fill_in "Latitude", with: @task.latitude
    fill_in "Longitude", with: @task.longitude
    fill_in "Place", with: @task.place
    fill_in "Start At", with: @task.start_at
    fill_in "Title", with: @task.title
    fill_in "Weather Infomation", with: @task.weather_infomation
    click_on "Create Task"

    assert_text "Task was successfully created"
    click_on "Back"
  end

  test "updating a Task" do
    visit tasks_url
    click_on "Edit", match: :first

    fill_in "Detail", with: @task.detail
    fill_in "Latitude", with: @task.latitude
    fill_in "Longitude", with: @task.longitude
    fill_in "Place", with: @task.place
    fill_in "Start At", with: @task.start_at
    fill_in "Title", with: @task.title
    fill_in "Weather Infomation", with: @task.weather_infomation
    click_on "Update Task"

    assert_text "Task was successfully updated"
    click_on "Back"
  end

  test "destroying a Task" do
    visit tasks_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Task was successfully destroyed"
  end
end
