module Support
  def try(method_name)
    public_send(method_name) if respond_to?(method_name)
  end
end
