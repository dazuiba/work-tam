require 'test_helper'

class PmModelsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:pm_models)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create pm_model" do
    assert_difference('PmModel.count') do
      post :create, :pm_model => { }
    end

    assert_redirected_to pm_model_path(assigns(:pm_model))
  end

  test "should show pm_model" do
    get :show, :id => pm_models(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => pm_models(:one).to_param
    assert_response :success
  end

  test "should update pm_model" do
    put :update, :id => pm_models(:one).to_param, :pm_model => { }
    assert_redirected_to pm_model_path(assigns(:pm_model))
  end

  test "should destroy pm_model" do
    assert_difference('PmModel.count', -1) do
      delete :destroy, :id => pm_models(:one).to_param
    end

    assert_redirected_to pm_models_path
  end
end
