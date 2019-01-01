require "csv"

class HistoryAnalysis
  def self.generate_sample_history_file
    start_dt = Time.new(2018,1,1)
    length_to_generate = 2.month.to_i
    total = 0

    output = []
    last_output_t = start_dt

    output << [start_dt.to_s(:iso), total].join("\t")

    CSV.open("sample_history.txt", "wb", col_sep: "\t") do |csv|
      length_to_generate.times do |sec|
        t = start_dt + sec

        if prob(0.005)
          max_seconds_on = (t - last_output_t).to_i

          rn = SecureRandom.random_number
          case
          when rn < 0.8
            seconds_on = 0
          when rn < 0.95
            seconds_on = max_seconds_on
          else
            seconds_on = SecureRandom.random_number(max_seconds_on)
          end

          total = total + seconds_on

          csv << [t.to_s(:iso), total, total.to_hms, max_seconds_on, seconds_on]
          last_output_t = t
        end
      end
    end
  end

  def self.prob(f)
    SecureRandom.random_number <= f
  end

  def self.load_history_file
    hist = []
    previous_val = 0
    CSV.read("sample_history.txt", col_sep: "\t").each do |row|
      dt = row[0].to_time
      total = row[1].to_i
      diff = total - previous_val
      previous_val = total

      hist << {dt: dt, total: total, diff: diff}
    end
    hist
  end

  def self.total_play_by_period(hist, period)
    grouped = hist.group_by_period(period) {|h| h[:dt]}
    grouped.map do |day, records|
      total_diffs = records.sum{|r| r[:diff]}
      minutes = total_diffs.to_f / 60.0
      [day, minutes.round(0), total_diffs.to_hms]
    end
  end
end
