require 'test_helper'

class PmFoldersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:pm_folders)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create pm_folder" do
    assert_difference('PmFolder.count') do
      post :create, :pm_folder => { }
    end

    assert_redirected_to pm_folder_path(assigns(:pm_folder))
  end

  test "should show pm_folder" do
    get :show, :id => pm_folders(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => pm_folders(:one).to_param
    assert_response :success
  end

  test "should update pm_folder" do
    put :update, :id => pm_folders(:one).to_param, :pm_folder => { }
    assert_redirected_to pm_folder_path(assigns(:pm_folder))
  end

  test "should destroy pm_folder" do
    assert_difference('PmFolder.count', -1) do
      delete :destroy, :id => pm_folders(:one).to_param
    end

    assert_redirected_to pm_folders_path
  end
end
