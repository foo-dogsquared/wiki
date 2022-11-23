import React from 'react';

const MyImage = ({ src, width, height, ...props }) => {
  return (
    <img src={src} placeholder="blur"/>
  );
};

export default MyImage;
