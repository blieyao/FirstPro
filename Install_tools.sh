#!/bin/bash

# 定义一个函数，用于下载和安装工具
install_tool() {
    TOOL_NAME=$1
    REPO_URL=$2

    echo "Fetching the latest version of $TOOL_NAME..."
    LATEST_VERSION=$(curl -s https://api.github.com/repos/$REPO_URL/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

    if [ -z "$LATEST_VERSION" ]; then
        echo "Error: LATEST_VERSION is empty for $TOOL_NAME. Please check the GitHub API response."
        exit 1
    fi

    echo "Latest version of $TOOL_NAME: $LATEST_VERSION"

    # 构造下载链接
    DOWNLOAD_URL="https://github.com/$REPO_URL/releases/download/$LATEST_VERSION/${TOOL_NAME}_${LATEST_VERSION#v}_linux_amd64.zip"

    echo "Download URL for $TOOL_NAME: $DOWNLOAD_URL"

    # 下载文件
    echo "Downloading $TOOL_NAME from $DOWNLOAD_URL..."
    curl -LO "$DOWNLOAD_URL"

    # 检查文件是否下载成功
    if [ ! -f "${TOOL_NAME}_${LATEST_VERSION#v}_linux_amd64.zip" ]; then
        echo "Error: Downloaded file for $TOOL_NAME not found. Please check the URL or your internet connection."
        exit 1
    fi

    # 解压文件
    echo "Extracting $TOOL_NAME..."
    unzip "${TOOL_NAME}_${LATEST_VERSION#v}_linux_amd64.zip"

    if [ $? -ne 0 ]; then
        echo "Failed to extract $TOOL_NAME. Please check if 'unzip' is installed and the downloaded file is valid."
        exit 1
    fi

    # 移动到 /usr/local/bin 以便全局使用
    echo "Installing $TOOL_NAME..."
    sudo mv $TOOL_NAME /usr/local/bin/

    if [ $? -ne 0 ]; then
        echo "Failed to install $TOOL_NAME. Please check your permissions."
        exit 1
    fi

    # 清理下载的文件
    echo "Cleaning up $TOOL_NAME files..."
    rm "${TOOL_NAME}_${LATEST_VERSION#v}_linux_amd64.zip"
    rm -f *.md

    echo "$TOOL_NAME $LATEST_VERSION has been installed successfully!"
}

# 安装 Nuclei
install_tool "nuclei" "projectdiscovery/nuclei"

# 安装 Naabu
install_tool "naabu" "projectdiscovery/naabu"

# 安装 Httpx
install_tool "httpx" "projectdiscovery/httpx"

# 安装 Subfinder
install_tool "subfinder" "projectdiscovery/subfinder"