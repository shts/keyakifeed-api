
json.array! @entries do |entry|
  json.id entry.id
  json.title entry.title
  json.url entry.url
  json.published entry.published
  json.image_url_list entry.image_url_list
  json.member_id entry.member.id
  json.member_name entry.member.name_main
  json.member_image_url entry.member.image_url
end
