# 13033 SMS Movement Permit 
This native iOS app was created to facilitate users during the Greek lockdown of autumn 2020 to generate the required SMS for their movement permit.

During the Greek lockdown citizens were required to get a movement permit via the 13033 SMS service. To do so they would compose an SMS in the format of "X FullName Address" and send it to the recipient "13033". X would be a number between 1-6 depending on their reason of movement and the official guidelines.   
eg. for physical exercise outdoors the user should send "6 John Doe JohnDoesAddress".

The app shows a list of the available reasons of movement with an icon and a short description for each.  
At the personal info tab the user stores their info.  
User taps their selection and the SMS is auto-composed with the recipient and SMS body.

App icons by Icons8: https://icons8.com

Special thanks to Paul Hudson for his teaching material on Swift coding language:  
https://www.hackingwithswift.com  
https://github.com/twostraws

Important:   
Please note that the MessageUI framework is not available in XCode's simulator - https://help.apple.com/simulator/mac/current/#/devb0244142d - so you won't see the SMS appear unless you run it on a physical device. Running in simulator you'll reach up to the "Attention; SMS services not available" alert.
