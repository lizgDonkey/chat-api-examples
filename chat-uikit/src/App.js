import React, { useState, useCallback } from "react";
import { Input, Button, message } from "antd";
import { EaseApp } from "es-uikit";
import { getToken } from "./api/getToken";
import "./App.css";
import "antd/dist/antd.css";

function App() {
	const [values, setValues] = useState({
		username: "",
		nickName: "",
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

	window.WebIM.conn &&
		window.WebIM.conn.addEventHandler("msg", {
			onConnected: (msg) => {
				console.log(">>>登录成功");
			},
			onOpened: (msg) => {
				console.log("登陆成功>>>");
			},
		});

	const onLogin = useCallback(() => {
		if (!values.username) {
			return message.error("username is required");
		} else if (!values.nickName) {
			return message.error("nickName is required");
		}
		getToken(values.username, values.nickName).then((res) => {
			const { accessToken } = res;
			console.log(accessToken);
			setAuthToken(accessToken);
		});
	}, [values]);

	const onClose = () => {
		window.WebIM.conn.close();
	};
	const onConversation = () => {
		let session = {
			sessionType: "singleChat",
			sessionId: "lizg2",
		};
		EaseApp.addSessionItem(session);
	};
	return (
		<div className="App">
			<h2> Agora Chat UIkit Examples </h2>
			<div>
				<label className="App-lable"> UserName </label>
				<Input
					placeholder="UserName"
					className="App-input"
					onChange={handleChange("username")}
					value={values.username}
				></Input>
				<label className="App-lable"> NickName </label>
				<Input
					placeholder="NickName"
					className="App-input"
					onChange={handleChange("nickName")}
					value={values.nickName}
				></Input>
			</div>
			<Button type="primary" className="App-btn" onClick={onLogin}>
				Login
			</Button>
			<Button type="primary" className="App-btn" onClick={onClose}>
				Logout
			</Button>
			<Button type="primary" className="App-btn" onClick={onConversation}>
				OnConversation
			</Button>
			{authToken && (
				<EaseApp
					appkey="41117440#383391"
					username={values.username}
					agoraToken={authToken}
				/>
			)}
		</div>
	);
}

export default App;
