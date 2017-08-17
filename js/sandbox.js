import {
  requireNativeComponent,
  NativeModules,
  Platform,
  DeviceEventEmitter
} from 'react-native';

import React, {
  Component,
  PropTypes
} from 'react';

const _module = NativeModules.SandboxModule;


export default{
	  async getContentWithDictionary(filePath){
	  	var filelist = await _module.fileListWithPath(filePath);
		return	filelist;
	},

	iOSRootDir(){
		return _module.RCTSandboxRootDir;
	},

	iOSDocumentDir(){
		return _module.RCTSandboxDocumentDir;
	},

	async copy(from,to){
		return await _module.copy(from,to);
	},

	async deleteFile(filePath){
		return await _module.deleteFile(filePath);
	}
}