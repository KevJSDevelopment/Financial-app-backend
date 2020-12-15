require 'date'
class PlaidAccountsController < ApplicationController
    @@client = Plaid::Client.new(env: "sandbox", client_id: ENV["CLIENT_ID"], secret: ENV["SANDBOX_SECRET"])
    # public_key: ENV["PUBLIC_KEY"])

    # response = @@client.sandbox.sandbox_public_token.create(
    #     institution_id: "ins_109508",
    #     initial_products: ['transactions']
    # )
    # # The generated public_token can now be
    # # exchanged for an access_token
    # publicToken = response.public_token
    # exchange_token_response = @@client.item.public_token.exchange(publicToken)
    
    def create_link_token
        token = request.headers["Authentication"].split(" ")[1]
        user = User.find(decode(token)["user_id"])
        
        if user
            link_token_response = @@client.link_token.create(
                user: {
                    client_user_id: "#{user.id}"
                    # params[:user_id]
                },
                client_name: "Evergreen",
                # params[:user_name],
                products: %w[auth transactions],
                country_codes: ['US'],
                language: 'en',
                link_customization_name: 'default',
                account_filters: {
                    depository: {
                    account_subtypes: %w[checking savings]
                    }
                }
            )
            link_token = link_token_response.link_token
            
            render json: {
                auth: true,
                link: link_token
            }
        else
            render json: {
                auth: false,
                message: "user not found"
            }
        end
    end

    # on user adding new institution 
    def get_access_token 
        
        token = request.headers["Authentication"].split(" ")[1]
        user = User.find(decode(token)["user_id"])
        if user
            link_token_response = @@client.item.public_token.exchange(params['public_token']) # get access
            
            access_token = link_token_response[:access_token]
            item_id = link_token_response[:item_id]
            # create plaid item (institution)
            pi = PlaidAccount.create({
                p_access_token: access_token,
                user_id: user.id,
                p_item_id: item_id, 
                p_institution: params['institution'] 
            })
            
            transactions = getTransactions(pi, user)
            
            accounts = getBalances(pi, user)
            render json: {
                auth: true, 
                transactions: transactions, 
                accounts: accounts
            }
        else
            render json: {
                auth: false, 
                message: "User not found for access"
            }
        end
    end                  
    
    def index
        token = request.headers["Authentication"].split(" ")[1]
        user = User.find(decode(token)["user_id"])
        accounts = PlaidAccount.where(user_id: user.id)
        if user
            render json: {
                auth: true,
                accounts: PlaidAccount.get_transactions(accounts)
            }
        else
            render json: {
                auth: false,
                message: user.errors.full_messages
            }
        end
    end

    # def getData # account will have many institutions. make fetch for each institution and consolidate 
    #     accounts = []
    #     transactions = []
    #     account = User.find(params['id']) # get their account
    #     plaidItems = account.plaid_items # get all items related to their account
    #     plaidItems.each do |item| # get data for each and rack em up
    #         user = item.user # owner of plaid item
    #         transactions << getTransactions(item, user)
    #         accounts << getBalances(item, user)
    #     end
    #     # if no plaid items {trans: [], accounts: []}, each item is an array. 
    #     render json: {transactions: transactions.flatten, accounts: accounts.flatten}
    # end


    def getTransactions(item, user)
        now = Date.today
        
        year_ago = (now - 30)
        
        begin
            product_response = @@client.transactions.get(item.p_access_token, year_ago, now)
            transactions = product_response.transactions.map do |transaction|  # map user into each transaction object 
                category_names = TransactionCategory.all.map do |category|
                    category.name
                end 
                
                if category_names.include? transaction.category[0] 
                    trans_category = TransactionCategory.find_by(name: transaction.category[0])
                else
                    trans_category = TransactionCategory.create(name: transaction.category[0])
                end
                
                Transaction.create(plaid_account_id: item.id, value: transaction.amount, date: transaction.date, description: transaction.category[1], transaction_category_id: trans_category.id)
                transaction[:user] = {username: user.name, id: user.id} # add a user key and set it to the owner
                transaction[:institution] = item.p_institution # add institution name
                transaction[:item_id] = item.p_item_id
                transaction
            end
        rescue Plaid::PlaidAPIError => e
            error_response = format_error(e)
            transactions =  error_response
        end
        
        return transactions # [ {trans}, {trans}, {trans}]
    end

    def getBalances(item, user)
        begin
            product_response = @@client.accounts.balance.get(item.p_access_token)
            balances = product_response.accounts.map do |account| 
                account[:user] = {username: user.name, id: user.id}
                account[:institution] = item.p_institution
                account[:item_id] = item.p_item_id
                account
            end
        rescue Plaid::PlaidAPIError => e
            error_response = format_error(e)
            balances = error_response
        end
        return balances # [ {acc}, {acc}, {acc}] 
    end


    # def transactionsForMonth
    #     transactions = []
    #     year = 2020
    #     month = params[:month].to_i
    #     month_start = Date.new(year, month, 1)  #=> #<Date: 2017-05-01 ...>
    #     month_end = Date.new(year, month, -1) 
    #     account = Account.find(params['account_id'])
    #     plaidItems = account.plaid_items
    #     plaidItems.each do |item|
    #         user = item.user 
    #         begin
    #             product_response = @@client.transactions.get(item.p_access_token, month_start, month_end)
    #             productTransactions = product_response.transactions.map do |transaction| 
    #                 transaction[:user] = {username: user.username, id: user.id} # add a user key and set it to the owner
    #                 transaction[:institution] = item.p_institution # add institution name
    #                 transaction[:item_id] = item.p_item_id
    #                 transaction
    #             end
    #         rescue Plaid::PlaidAPIError => error_response
    #             error_response = format_error(e)
    #             productTransactions =  error_response
    #         end
    #         transactions << productTransactions
    #     end
    #     render json: transactions.flatten
    # end

    # def deleteItem 
    #     item = PlaidAccount.find_by(p_item_id: params[:id])
    #     item_id = item.p_item_id
    #     @@client.item.remove(item.p_access_token)
    #     item.destroy()
    #     render json: {item_id: item_id}
    # end


    # def format_error(err)
    #     { 
    #         error: {
    #             error_code: err.error_code,
    #             error_message: err.error_message,
    #             error_type: err.error_type
    #         }
    #     }
    # end

    # def strong_params
    #     params.permit(:institution)
    # end
end
