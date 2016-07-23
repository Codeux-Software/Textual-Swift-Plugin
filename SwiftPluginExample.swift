
/* We create a class that inherits from NSObject so we need Foundation. */
import Foundation

/* As Textual creates a new instance of our primary class when the plugin
loads, it must inherit NSObject to allow proper initialization. */
/* THOPluginProtocol is the protocol available for plugin specific callbacks.
It is appended to our new class object to inform Swift that we conform to it. */

class TPI_SwiftPluginExample: NSObject, THOPluginProtocol
{
	var subscribedServerInputCommands: [String] {
		get {
			return ["privmsg", "notice"]
		}
	}

	func didReceiveServerInput(_ inputObject: THOPluginDidReceiveServerInputConcreteObject, on client: IRCClient)
	{
		/* Swift provides a very powerful switch statement so
		it is easier to use that for identifying commands than
		using an if statement if more than the two are added. */
		switch (inputObject.messageCommand) {
			case "PRIVMSG":
				handleIncomingPrivateMessageCommand(inputObject, on: client)
			case "NOTICE":
				handleIncomingNoticeCommand(inputObject, on: client)
			default:
				return
		}
	}

	func handleIncomingPrivateMessageCommand(_ inputObject: THOPluginDidReceiveServerInputConcreteObject, on client: IRCClient)
	{
		/* Get message sequence of incoming message. */
		let messageReceived = inputObject.messageSequence

		let messageParamaters = inputObject.messageParamaters

		/* Get channel that message was sent from. */
		/* The first paramater of the PRIVMSG command is always
		the channel the message was targetted to. */
		let senderChannel = client.findChannel(messageParamaters[0])

		/* Do not accept private messages. */
		if ((senderChannel?.isPrivateMessage) != nil) {
			return
		}

		/* Get sender of message. */
		let messageSender = inputObject.senderNickname

		/* Ignore this user, he's kind of a jerk. :-( */
		if messageSender.hasPrefix("Alex") {
			return
		}

		/* Compare it against a specific value. */
		if (messageReceived == "do you know what time it is?" ||
			messageReceived == "does anybody know what time it is?")
		{
			/* Format message. */
			let formattedString = (messageSender + ", the time where I am is: " + formattedDateTimeString())

			/* Invoke the client on the main thread when sending. */
			performBlock(onMainThread: {
				client.sendPrivmsg(formattedString, to: senderChannel!)
			})
		}
	}

	func handleIncomingNoticeCommand(_ inputObject: THOPluginDidReceiveServerInputConcreteObject, on client: IRCClient)
	{
		// Not implemented
	}

	/* Support a new command in text field. */
	var subscribedUserInputCommands: [String] {
		get {
			return ["datetime"]
		}
	}

	func userInputCommandInvoked(on client: IRCClient, command commandString: String, messageString: String)
	{
		let formattedString = ("The current time is: " + formattedDateTimeString())

		let mainWindow = masterController().mainWindow

		performBlock(onMainThread: {
			client.sendPrivmsg(formattedString, to:mainWindow.selectedChannel!)
		})
	}

	/* Helper functions. */
	func formattedDateTimeString() -> (String)
	{
		let dateFormatter = DateFormatter()
		
		dateFormatter.dateStyle = .full
		dateFormatter.timeStyle = .full
		
		let formattedDate = dateFormatter.string(from: Date())
		
		return formattedDate
	}
}
