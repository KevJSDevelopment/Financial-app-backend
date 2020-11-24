class UsersController < ApplicationController

    def create
        user = User.new(name: params[:username], password: params[:password])
        if user.save
            render json: {
                auth: true,
                user: user,
                budgets: [],
                token: encode({user_id: user.id})
            }
        else
            render json: {
                auth: false,
                info: user.errors.full_messages
            }
        end

    end

    def login
        # byebug
        user = User.find_by(name: params[:username])
        if user && user.authenticate(params[:password])
            render json: {
                auth: true,
                user: user,
                budgets: user.budgets,
                token: encode({user_id: user.id})
            }
        else
            render json: {
                auth: false,
                info: ["password or username was not valid, please try again"]
            }
        end
    end

end
