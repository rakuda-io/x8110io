# User.create!(
#   [
#     #user_01
#     {
#       name: 'Koume-chan',
#       email: 'koume@example.com',
#       password: 'password',
#       password_confirmation: 'password'
#     },
#     #user_02
#     {
#       name: 'Yuki-kun',
#       email: 'yuki@example.com',
#       password: 'password',
#       password_confirmation: 'password'
#     },
#     #user_03
#     {
#       name: 'Shino-san',
#       email: 'shino@example.com',
#       password: 'password',
#       password_confirmation: 'password'
#     },
#   ]
# )

Holding.create!(
  [
    #user_01
    {
      stock_id: 6961, # SPYD
      quantity: 12.5,
      user_id: 4,
    },
    {
      stock_id: 3405, # HDV
      quantity: 7.3,
      user_id: 4,
    },
    {
      stock_id: 7992, #VYM
      quantity: 22.8,
      user_id: 4,
    },
    #user_02
    {
      stock_id: 6980, # SPYD
      quantity: 38.3,
      user_id: 5,
    },
    {
      stock_id: 4152, # JNJ
      quantity: 1.0,
      user_id: 5,
    },
    {
      stock_id: 3405, # HDV
      quantity: 4.1,
      user_id: 5,
    },
    {
      stock_id: 5768, #PG
      quantity: 0.8,
      user_id: 5,
    },
    {
      stock_id: 7175, # T
      quantity: 3.9,
      user_id: 5,
    },
    {
      stock_id: 4308, # KO
      quantity: 8.0,
      user_id: 5,
    },
    {
      stock_id: 6895, #SOXL
      quantity: 22.1,
      user_id: 5,
    },
    #user_03
    {
      stock_id: 6961, # SPYD
      quantity: 15.0,
      user_id: 6,
    },
    {
      stock_id: 4152, # JNJ
      quantity: 45.0,
      user_id: 6,
    },
  ]
)
