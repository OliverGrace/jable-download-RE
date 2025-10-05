// 通过postMessage获取扩展配置参数
(function() {
    let config = null;
    // 监听来自content的配置消息
    // console.log('监听来自content的配置消息');
    window.addEventListener('message', event=> {
        if (event.source !== window) return;
        if (event.data && event.data.type === 'JABLE_SETTINGS') {
            // console.log('监听来自content的配置消息 JABLE_SETTINGS',event.data.settings);
            config = event.data.settings || {};
            renderDownloadButton();
        }
    });

    // 编码字符串为 Base64
    function encodeBase64(str) {
    const bytes = new TextEncoder().encode(str); // UTF-8 编码
    const binary = Array.from(bytes).map(b => String.fromCharCode(b)).join('');
    return btoa(binary)
        .replace(/\+/g, '-')  // URL safe
        .replace(/\//g, '_')  // URL safe
        .replace(/=+$/, '');  // 去掉末尾=
}

    function renderDownloadButton() {
        // console.log('config',config);
        // hlsUrl 是 m3u8地址（假设外部有定义或后续补充）
        let hlsUrl = typeof window.hlsUrl !== 'undefined' ? window.hlsUrl : '';
        let title = '';
        let ProtocolName = 'm3u8dl';
        let _downloadLinkTag = `<a id='jable-m3u8dl-download-btn' href='javascript:alert("未配置下载目录")' style='margin-left:10px;cursor:pointer;'> [ 未配置下载目录 ] </a>`;

        try {
            title = document.head.querySelector('[property="og:title"]').content;
        } catch (e) {
            title = document.title || '未命名';
        }

        
        if(hlsUrl && config && config.workDir){
            
            // 【重要】根据新的m3u8程序参数进行修改
            // 旧参数: --saveName "${title}" --workDir "..." --enableDelAfterDone --disableDateInfo
            // 新参数: --save-name "${title}" --save-dir "..." --del-after-done --no-date-info
            let M3U8dlProtocolParam = `${hlsUrl} --save-name "${title}" --save-dir "${config.workDir}" --del-after-done --no-date-info`;
            
            let b64Param = encodeBase64(M3U8dlProtocolParam);
            _downloadLinkTag = `<a id='jable-m3u8dl-download-btn' href='${ProtocolName}://${b64Param}' style='margin-left:10px;cursor:pointer;'> [ 下载 ] </a>`;
        }
        
        let titleconteinar = document.getElementsByClassName('header-left')[0];
        if (titleconteinar && titleconteinar.getElementsByTagName('h4')[0]) {
            // 确保不重复添加按钮
            let existingBtn = document.getElementById('jable-m3u8dl-download-btn');
            if (!existingBtn) {
                 titleconteinar.getElementsByTagName('h4')[0].innerHTML += _downloadLinkTag;
            } else {
                // 如果按钮已存在，只更新它的href属性
                let tempA = document.createElement('a');
                tempA.innerHTML = _downloadLinkTag;
                existingBtn.href = tempA.firstChild.href;
                existingBtn.innerHTML = tempA.firstChild.innerHTML;
                existingBtn.style.cssText = tempA.firstChild.style.cssText;
            }
        }
    }

    // 您可以根据需要取消注释下面的代码
    // 如果几秒后还没收到配置，也渲染一个提示按钮
    // setTimeout(function() {
    //     if (!config) {
    //         // 检查按钮是否已存在，避免重复渲染
    //         if (!document.getElementById('jable-m3u8dl-download-btn')) {
    //             config = { workDir: '' }; // 模拟一个空配置来渲染"未配置"按钮
    //             renderDownloadButton();
    //         }
    //     }
    // }, 5000);
})();
