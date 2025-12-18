class OfficeSettingsController < ApplicationController
  before_action :set_office_setting

  def edit
  end

  def update
    if @office_setting.update(office_setting_params)
      redirect_to edit_office_setting_path, notice: '事務所情報を更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_office_setting
    @office_setting = OfficeSetting.instance
  end

  def office_setting_params
    params.require(:office_setting).permit(
      :name,
      :postal_code,
      :address,
      :phone,
      :fax,
      :email,
      :bank_name,
      :branch_name,
      :account_type,
      :account_number,
      :account_holder
    )
  end
end
