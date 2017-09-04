class Numeric
  def to_hms(decimals = 0)
    int   = self.floor
    decs  = [decimals, 8].min
    frac  = self - int
    hms   = [int / 3600, (int / 60) % 60, int % 60].map { |t| t.to_s.rjust(2,'0') }.join(':')
    if decs > 0
      fp = (frac == 0) ? '.00' : "#{(frac).round(decs)}"[1..-1]
      hms  << fp
    end
    hms
  end
end