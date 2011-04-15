Date::DATE_FORMATS[:full_ordinal] = lambda { |date| date.strftime("%A, #{ActiveSupport::Inflector.ordinalize(date.day)} %B %Y") }
Date::DATE_FORMATS[:day_of_week] = "%A"