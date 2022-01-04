export const getToken = (agoraId, nickName) => {
	return postData("https://a41.easemob.com/app/chat/user/login", {
		userAccount: agoraId,
		userNickname: nickName,
	});
};

export function postData(url, data) {
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
