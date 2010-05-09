require 'test_helper'

class PmLibsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:pm_libs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create pm_lib" do
    assert_difference('PmLib.count') do
      post :create, :pm_lib => { }
    end

    assert_redirected_to pm_lib_path(assigns(:pm_lib))
  end

  test "should show pm_lib" do
    get :show, :id => pm_libs(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => pm_libs(:one).to_param
    assert_response :success
  end

  test "should update pm_lib" do
    put :update, :id => pm_libs(:one).to_param, :pm_lib => { }
    assert_redirected_to pm_lib_path(assigns(:pm_lib))
  end

  test "should destroy pm_lib" do
    assert_difference('PmLib.count', -1) do
      delete :destroy, :id => pm_libs(:one).to_param
    end

    assert_redirected_to pm_libs_path
  end
end
