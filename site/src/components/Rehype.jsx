import React from 'react';

import unified from 'unified';
import orgParse from 'uniorg-parse';
import org2rehype from 'uniorg-rehype';
import rehype2react from 'rehype-react';
import toc from '@jsdevtools/rehype-toc';

import Link from './Link';
import Image from './Image';

// we use rehype-react to process hast and transform it to React
// component, which allows as replacing some of components with custom
// implementation. e.g., we can replace all <a> links to use
// `next/link`.
const processor = unified()
    .use(rehype2react, {
  createElement: React.createElement,
  Fragment: React.Fragment,
  components: {
    a: Link,
    img: Image,
  },
});

const Rehype = ({ hast }) => {
  return <>{processor.stringify(hast)}</>;
};

export default Rehype;
