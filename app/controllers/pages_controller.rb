class PagesController < ApplicationController
  # ----- add these lines here: -----

  # Restrict access so only logged in users can access the secret page:
  before_action :authorize, only: [:secret]

  # ----- end of added lines -----

  def secret
  end
end