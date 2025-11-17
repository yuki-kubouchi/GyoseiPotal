require "application_system_test_case"

class CustomersTest < ApplicationSystemTestCase
  setup do
    @customer = customers(:one)
  end

  test "visiting the index" do
    visit customers_url
    assert_selector "h1", text: "Customers"
  end

  test "should create customer" do
    visit customers_url
    click_on "New customer"

    fill_in "Address", with: @customer.address
    fill_in "Code", with: @customer.code
    fill_in "Company name", with: @customer.company_name
    fill_in "Email", with: @customer.email
    fill_in "Kana", with: @customer.kana
    fill_in "Name", with: @customer.name
    fill_in "Notes", with: @customer.notes
    fill_in "Phone", with: @customer.phone
    fill_in "Status", with: @customer.status
    click_on "Create Customer"

    assert_text "Customer was successfully created"
    click_on "Back"
  end

  test "should update Customer" do
    visit customer_url(@customer)
    click_on "Edit this customer", match: :first

    fill_in "Address", with: @customer.address
    fill_in "Code", with: @customer.code
    fill_in "Company name", with: @customer.company_name
    fill_in "Email", with: @customer.email
    fill_in "Kana", with: @customer.kana
    fill_in "Name", with: @customer.name
    fill_in "Notes", with: @customer.notes
    fill_in "Phone", with: @customer.phone
    fill_in "Status", with: @customer.status
    click_on "Update Customer"

    assert_text "Customer was successfully updated"
    click_on "Back"
  end

  test "should destroy Customer" do
    visit customer_url(@customer)
    accept_confirm { click_on "Destroy this customer", match: :first }

    assert_text "Customer was successfully destroyed"
  end
end
