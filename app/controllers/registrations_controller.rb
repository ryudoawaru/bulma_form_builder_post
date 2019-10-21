class RegistrationsController < ApplicationController
  def new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to root_path
    else
      render action: :new
    end
  end

  def user_params
    params.require(:user).permit(:email, :passwd, :passwd_confirmation)
  end
end
