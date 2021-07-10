import React from 'react';
import config from '../../next.config.js';

const MyImage = ({ src, width, height, ...props }) => {
  const _src = `${config.basePath}${src}`
  return (
    <img src={_src} placeholder="blur"/>
  );
};

export default MyImage;
