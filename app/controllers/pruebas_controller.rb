# frozen_string_literal: true

class PruebasController < ApplicationController
  allow_unauthenticated_access

  def index
  end

  def mensaje
    @hora = Time.current.strftime("%H:%M:%S")
    render partial: "mensaje"
  end
end
