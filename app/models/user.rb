class User < ApplicationRecord
  encrypts :password
  encrypts :token
end
