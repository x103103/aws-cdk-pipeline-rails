# frozen_string_literal: true

class ApplicationController < ActionController::Base
  def root
    render json: { status: 'OK' }
  end
end
