function err = imageError(A,B,shift)
    
    l1 = [1 1];
    l2 = l1+shift;

    leftX   = max( l1(1), l2(1) );
    rightX  = min( l1(1) + size(A,1), l2(1) + size(B,1) );
    topY    = max( l1(2), l2(2) );
    bottomY = min( l1(2) + size(A,2), l2(2) + size(B,2) );

    if ( leftX < rightX && topY < bottomY ) 
      Ais = leftX:(rightX-1);
      Ajs = topY:(bottomY-1);
      
      Bis = Ais-shift(1);
      Bjs = Ajs-shift(2);
      
      err = sum(sum((A(Ais,Ajs)-B(Bis,Bjs)).^2))./(length(Ais)*length(Ajs));
%       err = sum(sum((A(Ais,Ajs).*B(Bis,Bjs)).^2))./(length(Ais)*length(Ajs));
      
      
      
    else
      err = NaN;
      return
    end


end
    

    