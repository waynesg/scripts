// [rule: ^(小爱)(.*)$]
// [rule: ^(菲菲)(.*)$]
// [rule: ^(青云)(.*)$]

var nickname = param(1)
var content = param(2)
var rename = function(content) {
    return content.replace("小爱", nickname).replace("菲菲", nickname).replace("{br}", "\n")
}
var data = request({
    "url": "http://api.qingyunke.com/api.php?key=free&appid=0&msg=" + content,
    "dataType": "json"
})
if (data && data.content) {
    sendText(rename(data.content))
} else {
    sendText(nickname + "刚放了个屁，容我缓缓！")
    data = request({
        "url": "https://jintia.jintias.cn/api/xatx.php?msg=" + content,
        "dataType": "json"
    })
    if (data && data.text) {
        sendText(rename(data.text))
    } else {
        sendText("暂时无法回复，先欣赏欣赏壁纸吧！")
        sendImage("https://api.mtyqx.cn/api/random.php")
    }
}