import React, { useState, useCallback } from "react";
import { Input, Button, message } from "antd";
import { EaseApp } from "chat-uikit";
// import { getToken } from "./api/getToken";
import "./App.css";
import "antd/dist/antd.css";

function App() {
	const [values, setValues] = useState({
		username: "",
		password: "",
	});
	const [authToken, setAuthToken] = useState("");
	const handleChange = (prop) => (event) => {
		let value = event.target.value;
		if (prop === "username") {
			value = event.target.value.replace(/[^\w\.\/]/gi, "");
		}
		setValues({
			...values,
			[prop]: value,
		});
	};

	const [to, setTo] = useState("");
	const handleChangeToValue = (event) => {
		let toValue = event.target.value;
		setTo(toValue);
	};

	// 从 app server 获取token
	const getToken = (username, password) => {
		return postData("https://a41.easemob.com/app/chat/user/login", {
			userAccount: username,
			userPassword: password,
		});
	};

	function postData(url, data) {
		return fetch(url, {
			body: JSON.stringify(data),
			cache: "no-cache",
			headers: {
				"content-type": "application/json",
			},
			method: "POST",
			mode: "cors",
			redirect: "follow",
			referrer: "no-referrer",
		}).then((response) => response.json());
	}

	const onLogin = useCallback(() => {
		if (!values.username) {
			return message.error("username is required");
		} else if (!values.password) {
			return message.error("password is required");
		}
		// 从 app server 获取token
		const getToken = (username, password) => {
			postData("https://a41.easemob.com/app/chat/user/login", {
				userAccount: username,
				userPassword: password,
			}).then((res)=> {
				const { accessToken } = res;
				setAuthToken(accessToken);
			})
		};

		function postData(url, data) {
			return fetch(url, {
				body: JSON.stringify(data),
				cache: "no-cache",
				headers: {
					"content-type": "application/json",
				},
				method: "POST",
				mode: "cors",
				redirect: "follow",
				referrer: "no-referrer",
			}).then((response) => response.json());
		}
		getToken(values.username, values.password);
	}, [values]);

	const loginSuccessCallback = (e) => {
		const WebIM = EaseApp.getSdk();
		WebIM.conn.addEventHandler("Logout", {
			onDisconnected: () => {
				console.log(">>>logout");
				setAuthToken("");
			},
		});
	};

	const onClose = () => {
		window.WebIM.conn.close();
	};
	const createConversation = () => {
		let conversationItem = {
			conversationType: "singleChat",
			conversationId: to,
		};
		EaseApp.addConversationItem(conversationItem);
		setTo("");
	};

	return (
		<div className="App">
			<h2> Agora Chat UIkit Examples </h2>
			<div>
				<label className="App-lable"> Username </label>
				<Input
					placeholder="Username"
					className="App-input"
					onChange={handleChange("username")}
					value={values.username}
				></Input>
				<label className="App-lable"> Password </label>
				<Input
					placeholder="Password"
					className="App-input"
					onChange={handleChange("password")}
					value={values.password}
				></Input>
				<Button type="primary" className="App-btn" onClick={onLogin}>
					Login
				</Button>
				<Button type="primary" className="App-btn" onClick={onClose}>
					Logout
				</Button>
			</div>
			<div>
				<label className="App-lable">To</label>
				<Input
					placeholder="UserID"
					className="App-input"
					onChange={handleChangeToValue}
					value={to}
				></Input>
				<Button
					type="primary"
					className="App-btn"
					onClick={createConversation}
				>
					CreateConversation
				</Button>
			</div>
			<div className="container">
				{authToken && (
					<EaseApp
						appkey="41117440#383391"
						username={values.username}
						agoraToken={authToken}
						successLoginCallback={loginSuccessCallback}
					/>
				)}
			</div>
		</div>
	);
}

export default App;
