# Travel Picture Reorganization problem
# Need to do a few things:
# Take a large string and split it up into objects with parts
# Rename objects based on their parts and relation to other object parts
# Keep the same order
#
# Steps:
# 1. Need to separate list into picture objects
#   - Object should have fields for name, extension, city, date+time, digits, number, and order
# 2. Need to transform data:
#   - Group Photos by City, then sort photos by time they were taken, then assign each a number space and number
# 3. Need to rename data and preserve original ordering:
#   - Old: <name>.<extension>, <city>, <date> <time>
#   - New: <city><number>.<extension>

class Picture
    attr_accessor :name, :extension, :city, :date_time, :order, :digits, :number

    def initialize (name, extension, city, date_time, order)
        @name = name
        @extension = extension
        @city = city
        @date_time = date_time
        @order = order
    end

    def print_picture
        puts "Picture:"
        puts "     Name: #{@name}"
        puts "Extension: #{@extension}"
        puts "     City: #{@city}"
        puts "Date_Time: #{@date_time}"
        puts "   Digits: #{@digits}"
        puts "   Number: #{@number}"
        puts "    Order: #{@order}"
        puts
    end
    
end

def string_to_time (date_str, time_str)
    date_arr = date_str.split("-")
    time_arr = time_str.split(":")

    date_time_arr = date_arr.push(time_arr).flatten
    date_time_arr.map! { |s| s.to_i }

    time_obj = Time.new(*date_time_arr)
end

def create_picture(str, order)
    pic = str.split(/(?:,\s|\s|\.)/) # regex meaning split on either ", ", " ", or "."

    picture = Picture.new(pic[0], pic[1], pic[2], string_to_time(pic[3], pic[4]), order)
end

def create_picture_array (str)
    picture_array = []
    order = 1
    string_array = str.split("\n")

    for line in string_array
        new_picture = create_picture(line, order)
        picture_array.push(new_picture)
        order = order+1
    end
    picture_array
end

def create_city_array (picture_array)
    city_array = picture_array.uniq {|p| p.city }
    city_array = city_array.map! {|p| p.city}
    city_array
end

def assign_digits_to_cities (picture_array)
    city_array = create_city_array(picture_array)

    city_numbers = city_array.map {|c| picture_array.count {|p| p.city == c} } # for each city, count how many pictures we have from there
    city_digits = city_numbers.map {|n| (Math.log10(n) + 1).floor } # Math equation for finding the digits in a number
    city_array = city_array.zip(city_digits)
    city_hash = Hash[city_array]
end

def assign_digits_to_pictures (picture_array)
    city_hash = assign_digits_to_cities(picture_array)

    # For each picture, we want to find its city in the hash and assign it the city's digits
    picture_array.map {|p| p.digits = city_hash.values_at(p.city)[0]}
end

def assign_numbers_to_city (city_pics)
    digits = city_pics[0].digits
    count = 1
    
    for pic in city_pics
        padding = digits - (Math.log10(count) + 1).floor # max digits - count digits = how many digits of padding to add
        number = count.to_s
        for p in (1..padding)
            number.insert(0, '0')
        end
        pic.number = number
        count = count + 1
    end
    city_pics
end

def assign_numbers_to_pictures(picture_array)
    city_array = create_city_array(picture_array)

    for cur_city in city_array
        city_pics = picture_array.select {|p| p.city == cur_city}

        city_pics.sort_by!(&:date_time)
        assign_numbers_to_city(city_pics)
    end
end

def rename_pictures (picture_array)
    for picture in picture_array
        new_name = "#{picture.city}#{picture.number}.#{picture.extension}"
        picture.name = new_name
    end
end

def return_solution_string (picture_array)
    solution_string = ""
    picture_array.map {|p| solution_string.concat(p.name).concat("\n")} 
    solution_string
end


def solution (s)
    picture_array = create_picture_array(s)

    assign_digits_to_pictures(picture_array)
    assign_numbers_to_pictures(picture_array)
    rename_pictures(picture_array)

    return_solution_string(picture_array)
end

test_string = %{photo.jpg, Krakow, 2013-09-05 14:08:15
Mike.png, London, 2015-06-20 15:13:22
myFriends.png, Krakow, 2013-09-05 14:07:13
Eiffel.jpg, Florianopolis, 2015-07-23 08:03:02
pisatower.jpg, Florianopolis, 2015-07-22 23:59:59
BOB.jpg, London, 2015-08-05 00:02:03
notredame.png, Florianopolis, 2015-09-01 12:00:00
me.jpg, Krakow, 2013-09-06 15:40:22
a.png, Krakow, 2016-02-13 13:33:50
b.jpg, Krakow, 2016-01-02 15:12:22
c.jpg, Krakow, 2016-01-02 14:34:30
d.jpg, Krakow, 2016-01-02 15:15:01
e.png, Krakow, 2016-01-02 09:49:09
f.png, Krakow, 2016-01-02 10:55:32
g.jpg, Krakow, 2016-02-29 22:13:11}

puts solution(test_string)
