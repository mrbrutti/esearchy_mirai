require 'rest-client'


module ESearchy
  module Helpers
  	# Disclaimer: 
  	# This module is based on a tool created by Ariel Matias Sanchez 
  	# and also based on research from Cesar Cerrudo.
    class Discover

        class << self

        	def search_in_all(e)

        	end

        	def icloud?(e)
                return post({   
                            :url => "https://setup.icloud.com/setup/web/check_availability/#{e}", 
                            :params => {
                                        :appleId => e, 
                                        :password => "Test0987", 
                                        :firstName => "Test", 
                                        :lastName => "ESearchy"
                                        }, 
                    
                            :headers => {
                                        "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/534.57.7 (KHTML, like Gecko)",  
                                         "Accept" => "*/*", 
                                         "Origin" => "https://setup.icloud.com", 
                                         "X-Requested-With" => "XMLHttpRequest", 
                                         "Content-Type" => "application/x-www-form-urlencoded", 
                                         "Referer" => "https://setup.icloud.com/setup/create_account_ui"
                                         },
                            :match => "\"success\":false"
                            })
    		end

        	def wsj?(e)
                return get({
                            :url => "https://id.wsj.com/auth/roles/forgotpassword",
                            :params => "emailId=#{e}&product=WSJ",
                            :headers => {:Referer => "http://commerce.wsj.com"},
                            :match => "<uuid>"
                            })
        	end

        	def nikeplus?(e)
                return get({
                            :url => "https://secure-nikerunning.nike.com/nsl/services/user/email/check",
                            :params => "format=json&app=b31990e7-8583-4251-808f-9dc67b40f5d2&email=#{e}",
                            :headers => {:Referer => "https://secure-nikerunning.nike.com"},
                            :match => "\"doesEmailExists\": \"true\""
                            })
        	end

        	def ask?(e)
                return get({
                            :url => "http://www.ask.com/ja-check-user",
                            :params => "email=#{e}&engine_id=add_user",
                            :headers => {},
                            :match => "User Found"
                            })
        	end

        	def garmin?(e)
                return get({
                            :url => "https://gems.garmin.com/componentServices/ValidateCreateAccount",
                            :params => "action=validate&callback=jsonp1327585609948&email=#{e}",
                            :headers => {:Referer => "https://gems.garmin.com"},
                            :match => "jsonp1327585609948(false)"
                            })
        	end

        	def payroll_intuit?(e)
                return get({
                            :url => "https://payroll.intuit.com/iop/sui/api/check_user_id.js",
                            :params => "reqType=checkUserId&uid=#{e}",
                            :headers => {},
                            :match => "false"
                            })
            end

        	def twitter?(e)
                return get({
                            :url => "https://twitter.com/users/email_available",
                            :params => "email=#{e}&context=front",
                            :headers => {},
                            :match => "false"
                            })
        	end

        	def hulu?(e)
                return get({
                            :url => "https://secure.hulu.com/account/check_email",
                            :params => "email=#{e}",
                            :headers => {},
                            :match => "email_exist"
                            })
        	end

        	def myspace?(e)
                return get({
                            :url => "https://www.myspace.com/Modules/PageEditor/Handlers/Signup/ValidateEmail.ashx",
                            :params => "email=#{e}",
                            :headers => {},
                            :match => "Already used, try another email address" #This will change depending on the country. 
                            })
        	end

        	def orbitz?(e)
                return get({
                            :url => "https://www.orbitz.com/Secure/SubmitMemberReg",
                            :params => "z=3d70&r=1y&memberName%3Atitle=--&memberName%3AfirstName=&memberName%3AmiddleInitial=&memberName%3AlastName=&memberName%3Asuffix=--&gender=--&memberEmail%3Aemail=#{e}&memberEmail%3AretypeEmail=&memberHomeCity%3AhomeCityAirport=&password=&retypePassword=&passwordHint=&Agree.x=&Agree=",
                            :headers => {},
                            :match => "matches the ID of a registered Orbitz member"
                            })
        	end

        	def google?(e)
                return get({
                            :url => "https://accounts.google.com/CreateAccount",
                            :params => "Email=#{e}",
                            :headers => {},
                            :match => "already a Google Account"
                            })
        	end

        	def naymz?(e)
                return get({
                            :url => "https://www.naymz.com/login/prepare_reset_password.action",
                            :params => "user.username=#{e}",
                            :headers => {},
                            :match => "change your password"
                            })
        	end

        	def posterous?(e)
                return get({
                            :url => "https://posterous.com/main/available_email",
                            :params => "email=#{e}",
                            :headers => {},
                            :match => "false"
                            })
        	end

        	def skype?(e)
                return get({
                            :url => "https://login.skype.com/json/validator",
                            :params => "email_repeat=#{e}&email=#{e}",
                            :headers => {"Referer" => "https://login.skype.com"},
                            :match => "You already have a Skype"
                            })
        	end

        	def plaxo?(e)
                return get({
                            :url => "http://www.plaxo.com/signup",
                            :params => "t=ajax&avail=true&email=#{e}",
                            :headers => {"Referer" => "http://www.plaxo.com/signup"},
                            :match => "Claimed"
                            })
        	end

        	def washingtonpost?(e)
                return get({
                            :url => "http://www.washingtonpost.com/ac2/wp-dyn/emailcheck",
                            :params => "email_add=#{e}",
                            :headers => {"Referer" => "http://www.washingtonpost.com"},
                            :match => "<existence>true</existence>"
                            })
        	end

        	def gartner?(e)
                return get({
                            :url => "https://www.gartner.com/technology/user/pcpreg/pcpAjaxuser.do",
                            :params => "name.primaryEmail=#{e}",
                            :headers => {"Referer" => "https://www.gartner.com"},
                            :match => "bad"
                            })
        	end

        	def dropbox?(e)
                return post({
                            :url => "https://www.dropbox.com/register",
                            :params => {:email => e},
                            :headers => {"Referer" => "http://www.dropbox.com"},
                            :match => "This e-mail is already taken"
                            })
        	end

        	def lhw?(e)
                return post({
                            :url => "https://www.lhw.com/members/Account/CheckAvailableMail",
                            :params => {:email => e},
                            :headers => {"Referer" => "http://www.lhw.com"},
                            :match => "false"
                            })
        	end

        	def a_club?(e)
                return post({
                            :url => "https://secure.a-club.com/en/already-member.action",
                            :params => {
                                        :email => e,
                                        :confirmationEmail => e
                                        },
                            :headers => {"Referer" => "https://secure.a-club.com"},
                            :match => "Please try again or use another e-mail address"
                            })
        	end

        	def businessinsider?(e)
                return post({
                            :url => "https://www.businessinsider.com/register",
                            :params => {
                                        :form_id => "user_register", 
                                        :mail => e
                                        },
                            :headers => {"Referer" => "https://www.businessinsider.com/register"},
                            :match => "<span>Already In Use</span>"
                            })
        	end

        	def economist?(e)
                return post({
                            :url => "https://www.economist.com/user/register",
                            :params => {
                                        :form_id => "user_register", 
                                        :mail => e
                                        },
                            :headers => {"Referer" => "https://www.economist.com/user/register"},
                            :match => "is already registered"
                            })
        	end

        	def facebook?(e)
                return get({
                            :url => "https://www.facebook.com/ajax/login/help/identify.php",
                            :params => "select_user_url=%2Frecover.php&no_selection_url=%2Fhelp%2Fcontact.php%3Fshow_form%3Dcannot_identify%26flow%3Dpw_reset&instructions=password_reset&flow=pw_reset&skip_confirmation=1&__a=1&email=#{e}&did_submit=Search",
                            :headers => {"Referer" => "https://www.facebook.com"},
                            :match => "A security check is required to proceed"
                            })
        	end

        	def travelers?(e)
                return get({
                            :url => "https://mylogon.travelers.com/mylogon/RetrieveUserIdStep1.aspx",
                            :params => "AppCN=PLCUS&__VIEWSTATE=%2FwEPDwUJMzMxMDYwOTU1ZGQFJd7fxfEPkSOt7wRaIuPNbuV%2FIw%3D%3D&__EVENTVALIDATION=%2FwEWBAL5q%2Fz3DAKE8%2F26DAKYm8bUBwL2lqeXDZd5Ha5C8NtMXcxbKS37lijGGZS6&txtEmail=#{e}&btnContinue=Continue",
                            :headers => {"Referer" => "https://mylogon.travelers.com/mylogon/RetrieveUserIdStep1.aspx"},
                            :match => "Step 2 of 3"
                            })
        	end

        	def nytimes?(e)
                return post({
                            :url => "https://myaccount.nytimes.com/register",
                            :params => {
                                        "is_continue" => 1,
                                        "email_address" => e, 
                                        "password1" => "esearchy", 
                                        "password2" => "esearchy",
                                        "email_format" => "H",
                                        "subscribe[]" => "MM"
                                        },
                            :headers => {"Referer" => "https://myaccount.nytimes.com/register"},
                            :match => "is already associated with an account"
                            })
        	end

        	def wired?(e)
                return get({
                            :url => "https://secure.wired.com/user/registration",
                            :params => "command=submit&email=#{e}&password1=",
                            :headers => {"Referer" => "https://secure.wired.com"},
                            :match => "This email address is not available"
                            })
        	end

        	def marketwatch?(e)
                return post({
                            :url => "https://secure.marketwatch.com/user/registration/submitregistration",
                            :params => {"EmailAddress" => e},
                            :headers => {"Referer" => "https://secure.marketwatch.com"},
                            :match => "This email address is already in use"
                            })
        	end

        	def sonyentertainment?(e)
                return get({
                            :url => "https://account.sonyentertainmentnetwork.com/reg/account/validate-login-name.action",
                            :params => "loginName=#{e}",
                            :headers => {"Referer" => "https://account.sonyentertainmentnetwork.com"},
                            :match => "An account with this e-mail address already exists"
                            })
        	end

        	def accorhotels?(e)
                return post({
                            :url => "https://secure.accorhotels.com/user/isProfileCheck.action",
                            :params => {
                                        "user.email" => e, 
                                        "httpSessionId" => "lvCJP2kPXd2V6DQvl0GZWfvp6Jp73QXhc6KJ7CqNnx3GXKlxn110!-1589668407"
                                        },
                            :headers => {"Referer" => "https://secure.accorhotels.com"},
                            :match => "error.email.already.exists.login"
                            })
        	end

        	def samsung?(e)
                return post({
                            :url => "https://account.samsung.com/account/checkInputBasicInfo.do",
                            :params => {
                                        "serviceID" => "o12ht525e6", 
                                        "inputEmailID" => e
                                        },
                            :headers => {"Referer" => "https://account.samsung.com"},
                            :match => "This E-mail is already in use"
                            })
        	end

            def linkedin?(e)
                return post({
                            :url => "https://www.linkedin.com/uas/login-submit",
                            :params => {
                                        "session_key" => e,
                                        "session_password" => "XolLarP098"
                                        },
                            :headers => {"Referer" => "https://www.linkedin.com/uas/login-submit"},
                            :match => "The email address or password you provided does not match our records"
                            })
            end


        	#def bloomberg?(e)
            #    return post({
            #                :url => "",
            #                :params => {},
            #                :headers => {},
            #                :match => ""
            #                }
        	#end

            #def netflix?(e)
            #    return post({
            #                :url => "",
            #                :params => {},
            #                :headers => {},
            #                :match => ""
            #                }
            #end

            private
            def post(options)
                begin
                    response = RestClient.post options[:url], options[:params], options[:headers]
                    return response.match(options[:match]) != nil ? true : false
                rescue 
                    return false
                end
            end

            def get(options)
                begin
                    response = RestClient.get options[:url] + "?" + options[:params], options[:headers]
                    return response.match(options[:match]) != nil ? true : false
                rescue
                    return false
                end
            end
        end
    end
  end
end